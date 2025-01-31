import SwiftUI

struct AddEntryView: View {
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository()
    )

    @Environment(\.dismiss) private var dismiss

    @State private var content: String = ""
    @State private var translationDebounceTimer: Timer?
    @State private var startTime: Date? // ⏱ Startzeit speichern

    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    TextEditor(text: $content)
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .autocorrectionDisabled(true)
                        .onChange(of: content) { _, newValue in
                            handleTextChange(newValue: newValue)
                        }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text(translationViewModel.translatedText.isEmpty ? "Meine Übersetzung wird hier erscheinen ..." : translationViewModel.translatedText)
                        .foregroundColor(translationViewModel.translatedText.isEmpty ? colorManager.currentColor.color.opacity(0.5) : colorManager.currentColor.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    HStack {
                        Text("\(wordCount) Wörter")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        Task {
                            try await viewModel.createEntry(content: content) // ⏱ Speichert automatisch mit aktuellem Datum
                            dismiss()
                        }
                    }
                    .disabled(content.isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .task {
                await translationViewModel.fetchUserPreferredLanguage()
            }
        }
    }

    func handleTextChange(newValue: String) {
        // Starte den Timer nur beim ersten getippten Wort
        if startTime == nil && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            startTime = Date()
        }

        translationDebounceTimer?.invalidate()
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
