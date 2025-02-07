import SwiftUI

struct DetailView: View {
    @ObservedObject var translationViewModel: TranslationViewModel
    
    let entry: JournalEntry
    let entryViewModel: EntryViewModel
    let colorManager: ColorManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Anzeige des Eintragsinhalts
            Text(entry.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // HStack: links Dauer, mittig (optional) Aktualisierungsdatum und rechts Wortanzahl
            if let updated = entry.updatedAt {
                HStack {
                    Text("\(entryViewModel.formattedDuration(entry.duration)) min")
                    Spacer()
                    Text("Aktualisiert: \(updated.formatted(date: .abbreviated, time: .omitted))")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .padding(4)
            } else {
                HStack {
                    Text("\(entryViewModel.formattedDuration(entry.duration)) min")
                    Spacer()
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                }
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .padding(4)
            }
            
            // Übersetzungsbereich
            Text(translationViewModel.translatedText.isEmpty
                 ? "Übersetze ..."
                 : translationViewModel.translatedText)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(translationViewModel.translatedText.isEmpty
                             ? colorManager.currentColor.color.opacity(0.5)
                             : colorManager.currentColor.color)
            .padding(.top, 8)
        }
    }
}
