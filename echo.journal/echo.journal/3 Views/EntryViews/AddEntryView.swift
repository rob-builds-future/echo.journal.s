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
    
    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    TextEditor(text: $content)
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .autocorrectionDisabled(true)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .onChange(of: content) { _, newValue in
                            viewModel.startTimer(content: newValue)
                            translationViewModel.handleTextChange(newValue: newValue)
                        }
                    
                    HStack {
                        Spacer()
                        
                        Text("\(wordCount) Worte")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text(translationViewModel.translatedText.isEmpty ? "Hier werde ich für Dich übersetzen. Ich warte ..." : translationViewModel.translatedText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(translationViewModel.translatedText.isEmpty ? colorManager.currentColor.color.opacity(0.5) : colorManager.currentColor.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "xmark") // bbrechen-Icon
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
                
                ToolbarItem(placement: .principal) {
                    Text(viewModel.formattedDate(Date()))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            try await viewModel.createEntry(content: content)
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark") // Speichern-Icon
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(content.isEmpty ? Color(UIColor.systemGray4) : colorManager.currentColor.color)
                        )
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
}

#Preview {
    AddEntryView(viewModel: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: "testUser"), colorManager: ColorManager())
}
