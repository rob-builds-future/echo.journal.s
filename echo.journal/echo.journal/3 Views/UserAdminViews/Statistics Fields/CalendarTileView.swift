import SwiftUI

struct CalendarTileView: View {
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme
    
    private let today = Date()
    
    // Berechne nur Tage innerhalb des angezeigten Monats, an denen ein Journal-Eintrag existiert
    private var journaledDaysCount: Int {
        let days = statisticsViewModel.daysForDisplayedMonth()
        return days.filter { date in
            Calendar.current.isDate(date, equalTo: statisticsViewModel.displayedMonth, toGranularity: .month)
            && statisticsViewModel.hasEntry(on: date)
        }.count
    }
    
    var body: some View {
        ZStack {
            // Hintergrund der Kachel: Im Dark Mode schwarz, im Light Mode weiß
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 0)
            
            VStack(spacing: 8) {
                // Platzreserve für den Overlay-Header
                Spacer().frame(height: 40)
                
                // Navigationszeile: Vorher-/Nächsten-Buttons und Monatsanzeige
                HStack {
                    Button(action: statisticsViewModel.goToPreviousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    Spacer()
                    Text(statisticsViewModel.monthYearString)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                    Button(action: statisticsViewModel.goToNextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
                .padding(.horizontal, 16)
                
                // Wochentage
                HStack {
                    ForEach(statisticsViewModel.weekdays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
                .padding(.horizontal, 16)
                
                // Kalender-Gitter
                let days = statisticsViewModel.daysForDisplayedMonth()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { date in
                        ZStack {
                            if Calendar.current.isDate(date, equalTo: statisticsViewModel.displayedMonth, toGranularity: .month) {
                                if statisticsViewModel.hasEntry(on: date) {
                                    Circle()
                                        .fill(colorManager.currentColor.color) // ohne opacity
                                        .frame(width: 25, height: 25)
                                }
                                let isFuture = Calendar.current.compare(date, to: today, toGranularity: .day) == .orderedDescending
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(isFuture ? Color.gray : (colorScheme == .dark ? Color.white : Color.black))
                            } else {
                                Text("")
                            }
                        }
                        .frame(height: 30)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        // Overlay: Header – links Titel mit Hintergrund, rechts der Zähler
        .overlay(
            HStack {
                Text("Dein Schreib-Tracker")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        CustomCornerShape(topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 12)
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                    )
                Spacer()
                Text("\(journaledDaysCount) Tage")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.trailing, 16)
            },
            alignment: .top
        )
    }
}
