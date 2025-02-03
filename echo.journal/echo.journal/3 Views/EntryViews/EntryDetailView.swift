import SwiftUI
import AVFoundation

struct EntryDetailView: View {
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository()
    )
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var entry: JournalEntry              // Der anzuzeigende Eintrag
    @State private var isEditing: Bool = false          // Zustand für den Bearbeitungsmodus
    @State private var updatedContent: String = ""      // Bearbeiteter Inhalt des Eintrags
    
    // Speech Synthesizer und zugehöriger Status
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var speechState: SpeechState = .idle
    @StateObject private var speechDelegate = SpeechDelegate()
    
    // Eigener Initializer – dieser ist internal und somit in deinem Modul verfügbar
    init(viewModel: EntryViewModel, colorManager: ColorManager, entry: JournalEntry) {
        self.viewModel = viewModel
        self.colorManager = colorManager
        _entry = State(initialValue: entry)
    }
    
    private var wordCount: Int {
        updatedContent.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isEditing {
                        editView
                    } else {
                        detailView
                    }
                }
                .padding()
            }
            // Overlay-Button für Text-to-Speech, unten links
            .overlay(
                Button(action: {
                    toggleSpeech()
                }) {
                    Image(systemName: iconForSpeechState())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding()
                        .background(Circle().fill(colorManager.currentColor.color))
                        .foregroundColor(.white)
                }
                    .padding(),
                alignment: .bottomLeading
            )
        }
        .onAppear {
            // Setze den SpeechSynthesizer-Delegate, damit wir das Ende der Wiedergabe überwachen können
            speechSynthesizer.delegate = speechDelegate
            speechDelegate.onFinish = {
                speechState = .idle
            }
        }
        // Navigationstitel und Back-Button-Anzeige
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Linke Toolbar: X-Button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if isEditing {
                        // Verlasse den Edit Mode, ohne den gesamten View zu dismissen
                        exitEditMode()
                    } else {
                        // Dismiss den gesamten View (zur EntryListView)
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "xmark") // X-Icon
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 14)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray2))
                    )
                }
            }
            
            // Mittig: Anzeige des Erstellungsdatums
            ToolbarItem(placement: .principal) {
                Text(viewModel.formattedDate(entry.createdAt))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Rechte Toolbar:
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    // Im Edit Mode: Speichern-Button (hier wird das Checkmark-Icon verwendet)
                    Button(action: {
                        Task {
                            await viewModel.updateEntry(entryId: entry.id, content: updatedContent)
                            entry.content = updatedContent
                            isEditing = false
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule()
                                    .fill(colorManager.currentColor.color)
                            )
                    }
                } else {
                    // Im normalen Detailmodus: Bearbeiten-Button (Pen-Icon)
                    Button(action: {
                        enterEditMode()
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule()
                                    .fill(colorManager.currentColor.color)
                            )
                    }
                }
            }
        }
        // Im Detailmodus wird die Übersetzung geladen
        .task {
            if !isEditing {
                await translationViewModel.fetchUserPreferredLanguage()
                await translationViewModel.translateText(entry.content)
            }
        }
    }
    
    // MARK: - Detailansicht (Nur Lese-Modus)
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Anzeige des Eintragsinhalts
            Text(entry.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // HStack: links Dauer, mittig (optional) Aktualisierungsdatum und rechts Wortanzahl
            if let updated = entry.updatedAt {
                HStack {
                    Text("\(viewModel.formattedDuration(entry.duration))")
                    Spacer()
                    Text("Aktualisiert: \(updated.formatted(date: .abbreviated, time: .omitted))")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.footnote)
                .foregroundColor(.gray)
            } else {
                HStack {
                    Text("\(viewModel.formattedDuration(entry.duration))")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            
            // Übersetzungsbereich
            Text(translationViewModel.translatedText.isEmpty
                 ? "Übersetze ..."
                 : translationViewModel.translatedText)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(translationViewModel.translatedText.isEmpty
                             ? colorManager.currentColor.color.opacity(0.5)
                             : colorManager.currentColor.color)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Bearbeitungsansicht (Edit Mode)
    private var editView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TextEditor, der genauso aussieht wie in AddEntryView:
            TextEditor(text: $updatedContent)
                .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .autocorrectionDisabled(true)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .onChange(of: updatedContent) { _, newValue in
                    viewModel.startTimer(content: newValue)
                    translationViewModel.handleTextChange(newValue: newValue)
                }
            
            // Optional: Anzeige der Wortanzahl im Edit Mode (analog zu AddEntryView)
            HStack {
                Spacer()
                Text("\(wordCount) Worte")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            // Übersetzungsbereich (sowie im Detailmodus)
            Text(translationViewModel.translatedText.isEmpty
                 ? "Hier werde ich für Dich übersetzen. Ich warte ..."
                 : translationViewModel.translatedText)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(translationViewModel.translatedText.isEmpty
                             ? colorManager.currentColor.color.opacity(0.5)
                             : colorManager.currentColor.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: Edit Funktionen
    
    /// Wechselt in den Bearbeitungsmodus und lädt den aktuellen Inhalt.
    private func enterEditMode() {
        isEditing = true
        updatedContent = entry.content
        // Optional: Sofortige Übersetzung des bestehenden Inhalts im Edit Mode
        Task {
            await translationViewModel.fetchUserPreferredLanguage()
            await translationViewModel.translateText(entry.content)
        }
    }
    
    /// Verwirft Änderungen und verlässt den Bearbeitungsmodus.
    private func exitEditMode() {
        isEditing = false
        updatedContent = entry.content // Setzt den ursprünglichen Inhalt zurück
    }
    
    // MARK: - Text-to-Speech Funktionen
    private func speak(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        
        // Beispiel: Wähle eine bestimmte Stimme (hier "Luciana" für pt-BR, als Beispiel)
        if let chosenVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "Luciana" && $0.language == "pt-BR" }) {
            utterance.voice = chosenVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        }
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
        speechState = .playing
    }
    
    /// Toggle-Funktion für den TTS-Button
    private func toggleSpeech() {
        if speechSynthesizer.isSpeaking {
            if speechState == .playing {
                speechSynthesizer.pauseSpeaking(at: .word)
                speechState = .paused
            } else if speechState == .paused {
                speechSynthesizer.continueSpeaking()
                speechState = .playing
            }
        } else {
            // Wenn nichts spricht, starte die Wiedergabe
            speak(text: translationViewModel.translatedText)
            speechState = .playing
        }
    }
    
    /// Bestimmt das aktuell anzuzeigende Symbol basierend auf dem SpeechState
    private func iconForSpeechState() -> String {
        switch speechState {
        case .idle:
            return "speaker.wave.2.fill"  // Standard-Lautsprecher-Symbol
        case .playing:
            return "pause.fill"           // Pause-Symbol
        case .paused:
            return "play.fill"            // Play-Symbol
        }
    }
}
