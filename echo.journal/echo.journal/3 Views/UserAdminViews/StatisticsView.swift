import SwiftUI

struct StatisticsView: View {
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    init(entryViewModel: EntryViewModel,
         colorManager: ColorManager,
         translationViewModel: TranslationViewModel,
         statisticsViewModel: StatisticsViewModel) {
        self.statisticsViewModel = statisticsViewModel
        self.translationViewModel = translationViewModel
        self.colorManager = colorManager
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Schreibverhalten-Kachel
                StatisticsTileView(statisticsViewModel: statisticsViewModel, colorManager: colorManager)
                
                // Kalender-Kachel
                CalendarTileView(statisticsViewModel: statisticsViewModel, colorManager: colorManager)
                
                // Top-Words-Kachel (Liste mit Paging)
                TopWordsTileView(statisticsViewModel: statisticsViewModel, translationViewModel: translationViewModel, colorManager: colorManager)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            /// **Abbrechen-Button (links)**
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
            }
            // Mitte: Titel mit Benutzername
            ToolbarItem(placement: .principal) {
                Text("Deine Statistik")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}
