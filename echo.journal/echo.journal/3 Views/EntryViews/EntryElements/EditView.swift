import SwiftUI

struct EditView: View {
    @Binding var updatedContent: String
    @ObservedObject var translationViewModel: TranslationViewModel
    let viewModel: EntryViewModel
    let colorManager: ColorManager
    let wordCount: Int
    let isEditing: Bool

    var body: some View {
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
                    translationViewModel.handleTextChange(newValue: newValue, debounceTime: 0.3)
                }
            
            // Wortanzahl
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
}
