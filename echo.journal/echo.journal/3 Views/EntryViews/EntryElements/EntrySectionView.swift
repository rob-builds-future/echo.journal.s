import SwiftUI

struct EntrySectionView: View {
    @Binding var content: String
    var wordCount: Int
    @FocusState.Binding var textEditorFocused: Bool
    @State private var isTextViewFocused: Bool = false
    
    
    @ObservedObject var entryViewModel: EntryViewModel
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var inspirationViewModel: InspirationViewModel
    @ObservedObject var colorManager: ColorManager
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                TextViewWithCustomSpacing(
                    text: $content,
                    wordCount: wordCount,
                    onTextChange: { newText in
                        entryViewModel.startTimer(content: newText)
                        translationViewModel.handleTextChange(newValue: newText, debounceTime: 0.3)
                    },
                    isFocused: $textEditorFocused
                )
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemBackground))
                )
                
                
                if content.isEmpty, let currentInsp = inspirationViewModel.currentInspiration {
                    HStack(alignment: .top) {
                        Text(" \(currentInsp.text)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(colorManager.currentColor.color.opacity(0.5))
                            .padding(8)
                            .padding(.top, 4)
                        Spacer()
                        Button(action: {
                            inspirationViewModel.nextInspiration()
                        }) {
                            Text("e.")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle().fill(colorManager.currentColor.color)
                                )
                        }
                        .padding(.trailing, 8)
                        .padding(.top, 8)
                    }
                    .zIndex(1)
                }
            }
            
            HStack {
                Spacer()
                Text("\(wordCount) Worte")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 8)
    }
}
