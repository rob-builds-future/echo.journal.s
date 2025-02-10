import SwiftUI

struct StatisticsTileView: View {
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    @ObservedObject var colorManager: ColorManager

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Kachel-Hintergrund: Im Dark Mode schwarz, im Light Mode weiß
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 0)
            
            // Inhalt der Kachel: Grid mit den Statistiken
            VStack(spacing: 16) {
                Spacer().frame(height: 30)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    VStack {
                        Text("Gesamt Zeit")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text(statisticsViewModel.formattedDuration)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    VStack {
                        Text("Gesamt Worte")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text("\(statisticsViewModel.totalWords)")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    VStack {
                        Text("Ø Zeit")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text(statisticsViewModel.formattedAverageDuration)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    VStack {
                        Text("Ø Worte")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Text("\(Int(statisticsViewModel.averageWords))")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
            }
        }
        // Overlay: Header ganz oben in der Kachel
        .overlay(
            HStack {
                Text("Deine Schreib-Erfolge")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    // Im Dark Mode: Headerhintergrund weiß, Text schwarz; im Light Mode: umgekehrt.
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        CustomCornerShape(topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 12)
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                    )
                Spacer()
                Text("\(statisticsViewModel.totalEntries) Einträge")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.trailing, 16)
            },
            alignment: .top
        )
    }
}
