import SwiftUI

struct DetailView: View {
    @ObservedObject var translationViewModel: TranslationViewModel
    
    let entry: JournalEntry
    let viewModel: EntryViewModel
    let colorManager: ColorManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Anzeige des Eintragsinhalts
            Text(entry.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // HStack: links Dauer, mittig (optional) Aktualisierungsdatum und rechts Wortanzahl
            if let updated = entry.updatedAt {
                HStack {
                    Text("\(viewModel.formattedDuration(entry.duration))")
                    Spacer()
                    Text("Aktualisiert: \(updated.formatted(date: .abbreviated, time: .omitted))")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.footnote)
                .foregroundColor(.gray)
            } else {
                HStack {
                    Text("\(viewModel.formattedDuration(entry.duration))")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            
            // Übersetzungsbereich
            Text(translationViewModel.translatedText.isEmpty
                 ? "Übersetze ..."
                 : translationViewModel.translatedText)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(translationViewModel.translatedText.isEmpty
                             ? colorManager.currentColor.color.opacity(0.5)
                             : colorManager.currentColor.color)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}
