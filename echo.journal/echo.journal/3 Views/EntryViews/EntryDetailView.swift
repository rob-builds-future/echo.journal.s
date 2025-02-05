import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository()
    )
    @StateObject private var speechViewModel = SpeechViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var entry: JournalEntry              // Der anzuzeigende Eintrag
    @State private var isEditing: Bool = false          // Zustand für den Bearbeitungsmodus
    @State private var updatedContent: String = ""      // Bearbeiteter Inhalt des Eintrags
    
    let capsuleWidth: CGFloat = 60
    let capsuleHeight: CGFloat = 30
    
    // Eigener Initializer
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
                        EditView(
                            translationViewModel: translationViewModel,
                            updatedContent: $updatedContent,
                            viewModel: viewModel,
                            colorManager: colorManager,
                            wordCount: wordCount,
                            isEditing: isEditing
                        )
                    } else {
                        DetailView(
                            translationViewModel: translationViewModel,
                            entry: entry,
                            viewModel: viewModel,
                            colorManager: colorManager
                        )
                    }
                }
                .padding()
            }
            // Overlay-Button für Text-to-Speech, unten links
            .overlay(
                SpeechButtonView(
                    speechViewModel: speechViewModel,
                    textToSpeak: translationViewModel.translatedText,
                    color: colorManager.currentColor.color
                ),
                alignment: .bottomLeading
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Linke Toolbar: X-Button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if isEditing {
                        exitEditMode()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(Capsule().fill(Color(UIColor.systemGray2)))
                }
            }
            
            // Mittig: Anzeige des Erstellungsdatums
            ToolbarItem(placement: .principal) {
                Text(viewModel.formattedDate(entry.createdAt))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Rechte Toolbar: Bearbeiten oder Speichern
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
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
                            .frame(width: capsuleWidth, height: capsuleHeight)
                            .background(Capsule().fill(colorManager.currentColor.color))
                    }
                } else {
                    Button(action: { enterEditMode() }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: capsuleWidth, height: capsuleHeight)
                            .background(Capsule().fill(colorManager.currentColor.color))
                    }
                }
            }
        }
        .onAppear {
            Task {
                await translationViewModel.fetchUserPreferredLanguage()
                await translationViewModel.translateText(entry.content)
            }
        }
    }
    
    // MARK: - Edit Funktionen
    
    /// Wechselt in den Bearbeitungsmodus und lädt den aktuellen Inhalt.
    private func enterEditMode() {
        isEditing = true
        updatedContent = entry.content
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
}
