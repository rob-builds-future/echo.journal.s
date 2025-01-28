import SwiftUI

struct AddEntryView: View {
    @ObservedObject var viewModel: EntryViewModel // ViewModel für die Einträge
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository() // Use the centralized auth repository
    )
    
    @Environment(\.dismiss) private var dismiss // Um das Sheet zu schließen
    
    @State private var content: String = "" // Inhalt des neuen Eintrags
    @State private var translationDebounceTimer: Timer? // Timer für Debouncing
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Bereich 1: Textfeld
                VStack(alignment: .leading) {
                    TextEditor(text: $content)
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading) // Mindesthöhe 100 für Multi-Line
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Rahmen für das TextEditor
                        )
                        .autocorrectionDisabled(true) // Autokorrektur deaktivieren
                        .onChange(of: content) { _, newValue in
                            handleTextChange(newValue: newValue)
                        }
                }
                .padding()
                
                // Bereich 2: Übersetzung
                VStack(alignment: .leading) {
                    Text(translationViewModel.translatedText.isEmpty ? "Meine Übersetzung wird hier erscheinen ..." : translationViewModel.translatedText)
                        .foregroundColor(translationViewModel.translatedText.isEmpty ? colorManager.currentColor.color.opacity(0.5) : colorManager.currentColor.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Übersetzung oben links ausrichten
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss() // Schließe das Sheet
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        Task {
                            do {
                                try await viewModel.createEntry(content: content) // Direkter Aufruf
                                dismiss() // Schließe das Sheet nach erfolgreichem Speichern
                            } catch {
                                print("Fehler beim Speichern: \(viewModel.errorMessage ?? "Unbekannter Fehler")")
                            }
                        }
                    }
                    .disabled(content.isEmpty) // Deaktiviere Button während des Speicherns
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Keine Platzverschwendung für NavigationTitle
            .contentShape(Rectangle()) // Macht den gesamten Bereich des main VStack tappable
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .task {
                await translationViewModel.fetchUserPreferredLanguage()
            }
        }
    }
    
    func handleTextChange(newValue: String) {
        // Invalidate any existing timer to debounce input
        translationDebounceTimer?.invalidate()
        
        // Start a new debounce timer with a 1-second delay
        translationDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task {
                await translationViewModel.translateText(newValue)
            }
        }
    }
}


#Preview {
    AddEntryView(viewModel: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: "testUser"), colorManager: ColorManager())
}
