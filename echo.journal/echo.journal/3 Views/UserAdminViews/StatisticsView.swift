import SwiftUI

struct StatisticsView: View {
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    
    init(entryViewModel: EntryViewModel, colorManager: ColorManager, translationViewModel: TranslationViewModel) {
        _statisticsViewModel = StateObject(wrappedValue: StatisticsViewModel(entryViewModel: entryViewModel))
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
    }
}
