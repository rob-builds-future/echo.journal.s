import SwiftUI

struct StatisticsView: View {
    @StateObject private var statisticsViewModel: StatisticsViewModel

    init(entryViewModel: EntryViewModel) {
        _statisticsViewModel = StateObject(wrappedValue: StatisticsViewModel(entryViewModel: entryViewModel))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistik-Kachel (wie vorher)
                VStack(spacing: 10) {
                    Text("Gesamtdauer: \(statisticsViewModel.formattedDuration)")
                    Text("Gesamtworte: \(statisticsViewModel.totalWords)")
                    Text("Durchschnittliche Dauer pro Eintrag: \(statisticsViewModel.formattedAverageDuration)")
                    Text("Durchschnittliche Wörter pro Eintrag: \(Int(statisticsViewModel.averageWords))")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Kalender-Kachel (wie vorher)
                VStack(spacing: 10) {
                    HStack {
                        Button(action: statisticsViewModel.goToPreviousMonth) {
                            Image(systemName: "chevron.left")
                        }
                        Spacer()
                        Text(statisticsViewModel.monthYearString)
                            .font(.headline)
                        Spacer()
                        Button(action: statisticsViewModel.goToNextMonth) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        ForEach(statisticsViewModel.weekdays, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .font(.subheadline)
                        }
                    }
                    
                    let days = statisticsViewModel.daysForDisplayedMonth()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(days, id: \.self) { date in
                            ZStack {
                                if Calendar.current.isDate(date, equalTo: statisticsViewModel.displayedMonth, toGranularity: .month) {
                                    if statisticsViewModel.hasEntry(on: date) {
                                        Circle()
                                            .fill(Color.green.opacity(0.3))
                                            .frame(width: 30, height: 30)
                                    }
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .foregroundColor(.primary)
                                } else {
                                    Text("")
                                }
                            }
                            .frame(height: 40)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Top-Words-Kachel
                VStack(alignment: .leading, spacing: 10) {
                    Text("Top verwendete Wörter")
                        .font(.headline)
                    ForEach(statisticsViewModel.topWords, id: \.word) { wordItem in
                        HStack {
                            Text(wordItem.word.capitalized)
                            Spacer()
                            Text("\(wordItem.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}
