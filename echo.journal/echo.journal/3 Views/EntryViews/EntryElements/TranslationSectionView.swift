import SwiftUI

struct TranslationSectionView: View {
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    Text(translationViewModel.translatedText.isEmpty
                         ? "Hier werde ich für Dich übersetzen. Ich warte ..."
                         : translationViewModel.translatedText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(translationViewModel.translatedText.isEmpty
                                     ? colorManager.currentColor.color.opacity(0.5)
                                     : colorManager.currentColor.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id("translatedText")
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onChange(of: translationViewModel.translatedText) { _ in
                    // Wenn der übersetzte Text sich ändert, scrolle automatisch nach unten
                    withAnimation {
                        scrollViewProxy.scrollTo("translatedText", anchor: .bottom)
                    }
                }
            }
        }
    }
}
