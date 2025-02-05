import SwiftUI

struct StatisticsView: View {
    //    @ObservedObject var viewModel: StatisticsViewModel
    //
    var body: some View {
        //        ScrollView {
        //            VStack(spacing: 16) {
        //                StatisticTile(title: "Gesamtzeit gejournalt", value: "\(viewModel.totalJournalingTime) min")
        //                StatisticTile(title: "Anzahl geschriebener Wörter", value: "\(viewModel.totalWordCount)")
        //                StatisticTile(title: "Tage mit Journaling", value: "\(viewModel.totalJournalingDays)")
        //                StatisticTile(title: "Durchschnittliche Eintragslänge", value: "\(viewModel.averageEntryLength) Wörter")
        //                StatisticTile(title: "Durchschnittliche Eintragszeit", value: "\(viewModel.averageEntryTime) min")
        //
        //                JournalingCalendarView(journalingDays: viewModel.journalingDays)
        //
        //                FrequentWordsView(words: viewModel.frequentWords)
        //            }
        //            .padding()
        //        }
        //    }
        Text("Statistics")
    }
    //
    //struct StatisticTile: View {
    //    var title: String
    //    var value: String
    //
    //    var body: some View {
    //        VStack {
    //            Text(title)
    //                .font(.headline)
    //                .foregroundColor(.gray)
    //            Text(value)
    //                .font(.title2)
    //                .bold()
    //        }
    //        .frame(maxWidth: .infinity)
    //        .padding()
    //        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    //    }
    //}
    //
    //struct JournalingCalendarView: View {
    //    var journalingDays: [Date]
    //
    //    var body: some View {
    //        VStack(alignment: .leading) {
    //            Text("Journaling Tracker")
    //                .font(.headline)
    //                .padding(.bottom, 8)
    //            HStack(spacing: 4) {
    //                ForEach(0..<30, id: \..self) { day in
    //                    Circle()
    //                        .fill(journalingDays.contains(Calendar.current.date(byAdding: .day, value: -day, to: Date())!) ? Color.blue : Color.gray.opacity(0.3))
    //                        .frame(width: 12, height: 12)
    //                }
    //            }
    //        }
    //        .padding()
    //        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    //    }
    //}
    //
    //struct FrequentWordsView: View {
    //    var words: [(word: String, count: Int)]
    //
    //    var body: some View {
    //        VStack(alignment: .leading) {
    //            Text("Häufig verwendete Wörter")
    //                .font(.headline)
    //                .padding(.bottom, 8)
    //
    //            ForEach(words, id: \..word) { word in
    //                HStack {
    //                    Text(word.word.capitalized)
    //                    Spacer()
    //                    Text("\(word.count)×")
    //                        .foregroundColor(.gray)
    //                }
    //                .padding(.vertical, 4)
    //            }
    //        }
    //        .padding()
    //        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    //    }
    //}
}
