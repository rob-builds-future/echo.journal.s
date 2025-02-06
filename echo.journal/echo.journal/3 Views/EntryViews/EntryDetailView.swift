import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var entryViewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository()
    )
    @StateObject private var speechViewModel = SpeechViewModel()

    @Environment(\.dismiss) private var dismiss
    
    let entryId: String // Speichert nur die ID, um immer die aktuelle Version des Eintrags zu verwenden
    @State private var showDatePicker = false // Steuert die Sichtbarkeit des DatePickers

    let capsuleWidth: CGFloat = 60
    let capsuleHeight: CGFloat = 30

    init(viewModel: EntryViewModel, colorManager: ColorManager, entryId: String) {
        self.entryViewModel = viewModel
        self.colorManager = colorManager
        self.entryId = entryId
    }
    
    /// Holt den aktuellen Eintrag aus dem ViewModel anhand der ID
    private var entry: JournalEntry? {
        entryViewModel.entries.first { $0.id == entryId }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if entryViewModel.isEditing {
                        // Bearbeitungsansicht
                        EditView(
                            translationViewModel: translationViewModel,
                            updatedContent: $entryViewModel.updatedContent,
                            viewModel: entryViewModel,
                            colorManager: colorManager,
                            wordCount: entryViewModel.updatedContent.split { $0.isWhitespace || $0.isNewline }.count,
                            isEditing: entryViewModel.isEditing
                        )
                    } else if let entry {
                        // Detailansicht
                        DetailView(
                            translationViewModel: translationViewModel,
                            entry: entry,
                            viewModel: entryViewModel,
                            colorManager: colorManager
                        )
                    }
                }
                .padding()
            }
            // Overlay für Text-to-Speech Button
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
            /// **Linke Toolbar: Schließen oder Bearbeitung beenden**
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if entryViewModel.isEditing {
                        entryViewModel.exitEditMode()
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

            /// **Zentrale Toolbar: Anzeige oder Bearbeitung des Erstellungsdatums**
            ToolbarItem(placement: .principal) {
                if entryViewModel.isEditing {
                    // Klickbares Datum öffnet DatePicker im Bearbeitungsmodus
                    Button(action: { showDatePicker.toggle() }) {
                        Text(entryViewModel.selectedDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorManager.currentColor.color)
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            // DatePicker für das Erstellungsdatum (keine zukünftigen Daten erlaubt)
                            DatePicker("Datum auswählen", selection: Binding(
                                get: { entryViewModel.selectedDate ?? Date() },
                                set: { entryViewModel.selectedDate = $0 }
                            ), in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            
                            Button("Fertig") {
                                showDatePicker = false
                            }
                            .padding()
                        }
                        .presentationDetents([.medium])
                    }
                } else if let entry {
                    // Anzeige des Erstellungsdatums im Nicht-Bearbeitungsmodus
                    Text(entryViewModel.formattedDate(entry.createdAt))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
            }

            /// **Rechte Toolbar: Bearbeiten oder Speichern**
            ToolbarItem(placement: .navigationBarTrailing) {
                if entryViewModel.isEditing {
                    // Speichern-Button
                    Button(action: { Task { await entryViewModel.updateEntry(entryId: entryId) } }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: capsuleWidth, height: capsuleHeight)
                            .background(Capsule().fill(colorManager.currentColor.color))
                    }
                } else {
                    // Bearbeiten-Button
                    Button(action: { entryViewModel.enterEditMode(entryId: entryId) }) {
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
                if let entry = entry {
                    await translationViewModel.translateText(entry.content)
                }
            }
        }
    }
}
