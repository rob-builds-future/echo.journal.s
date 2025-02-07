import SwiftUI

struct EditView: View {
    @ObservedObject var translationViewModel: TranslationViewModel
    
    @Binding var updatedContent: String

    let entryViewModel: EntryViewModel
    let colorManager: ColorManager
    let wordCount: Int
    let isEditing: Bool
    
    @State private var isTextEditorFocused: Bool = false
    @FocusState private var textEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // TextEditor, der genauso aussieht wie in AddEntryView:
            TextEditor(text: $updatedContent)
                .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
                .padding(.bottom, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white) // Hintergrundfarbe für den Editor
                        //.shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2) // Schatten hinzufügen
                )
                .autocorrectionDisabled(true)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .focused($textEditorFocused) // Fokusbindung aktivieren
                .onAppear {
                    textEditorFocused = true // Cursor direkt setzen
                }
                .onChange(of: updatedContent) { _, newValue in
                    entryViewModel.startTimer(content: newValue)
                    translationViewModel.handleTextChange(newValue: newValue, debounceTime: 0.3)
                }
            Divider()
            // Wortanzahl
            HStack {
                Spacer()
                Text("\(wordCount) Worte")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(4)
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
            .padding(.top, 8)
        }
    }
}
