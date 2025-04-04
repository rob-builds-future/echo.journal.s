import SwiftUI

struct StatisticsHeaderView: View {
    @ObservedObject var colorManager: ColorManager

    let totalWords: Int
    let totalTime: Double

    var body: some View {
        HStack(alignment: .center) {
            // Gesamtzahl der Wörter
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "quote.closing")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorManager.currentColor.color)
                    Text("\(totalWords)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("statisticsHeaderWords")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            
            // Vertikaler Divider
            Divider()
                .frame(height: 40)
            
            // Gesamtdauer
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorManager.currentColor.color)
                    Text("\(Int(totalTime))")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("statisticsHeaderTime")
                        .bold()
                        .font(.caption)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
}
