import SwiftUI

struct TopWordRowView: View {
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    @Environment(\.colorScheme) var colorScheme

    // Speichern eines strukturierten Übersetzungsergebnis.
    @State private var translationResult: TopWordTranslation = TopWordTranslation(main: "", alternatives: [])
    
    let rank: Int
    let word: String
    let count: Int
    
    var body: some View {
        HStack {
            Text("\(rank).")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 30, alignment: .leading)
            
            Text("\(word.capitalized) (\(count))")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            // Zusammengesetzte Darstellung: Hauptübersetzung fett, Alternativen in Klammern normal.
            if translationResult.main.isEmpty {
                // Falls noch kein Ergebnis vorliegt, zeige den Originaltext als Fallback.
                Text(word.prefix(1).uppercased() + word.dropFirst())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(colorManager.currentColor.color)
                    .cornerRadius(4)
            } else {
                (
                    Text(translationResult.main).bold() +
                    (translationResult.alternatives.isEmpty ? Text("") : Text(" (" + translationResult.alternatives.joined(separator: ", ") + ")"))
                )
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .padding(4)
                .background(colorManager.currentColor.color)
                .cornerRadius(4)
            }
        }
        .onAppear {
            Task {
                let result = await translationViewModel.translationForTopWord(word)
                translationResult = result
            }
        }
    }
}
