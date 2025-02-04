import SwiftUI

struct SpeechButtonView: View {
    @ObservedObject var speechViewModel: SpeechViewModel
    var textToSpeak: String
    var color: Color
    
    var body: some View {
        Button(action: {
            speechViewModel.toggleSpeech(text: textToSpeak)
        }) {
            Image(systemName: speechViewModel.iconForSpeechState())
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding()
                .background(Circle().fill(color))
                .foregroundColor(.white)
        }
        .padding()
    }
}
