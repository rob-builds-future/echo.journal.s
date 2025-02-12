import SwiftUI

struct StatisticsView: View {
    // Observed Objects
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    
    // Environment Values
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Initializer
    init(userViewModel: UserViewModel,
         statisticsViewModel: StatisticsViewModel,
         translationViewModel: TranslationViewModel,
         colorManager: ColorManager) {
        self.userViewModel = userViewModel
        self.statisticsViewModel = statisticsViewModel
        self.translationViewModel = translationViewModel
        self.colorManager = colorManager
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Schreibverhalten-Kachel
                StatisticsTileView(
                    statisticsViewModel: statisticsViewModel,
                    colorManager: colorManager
                )
                
                // Kalender-Kachel
                CalendarTileView(
                    statisticsViewModel: statisticsViewModel,
                    colorManager: colorManager,
                    userCreatedAt: userViewModel.currentUser?.createdAt ?? Date()
                )
                
                // Top-Words-Kachel (Liste mit Paging)
                TopWordsTileView(
                    statisticsViewModel: statisticsViewModel,
                    translationViewModel: translationViewModel,
                    colorManager: colorManager)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // **Abbrechen-Button (links)**
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
            }
            // Mitte: Titel mit Benutzername (übersetzt)
            ToolbarItem(placement: .principal) {
                Text("statistics")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}
