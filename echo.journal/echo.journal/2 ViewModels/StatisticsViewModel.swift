import Foundation

class StatisticsViewModel: ObservableObject {
//    @Published var totalJournalingTime: Int = 0 // Minuten
//    @Published var totalWordCount: Int = 0
//    @Published var totalJournalingDays: Int = 0
//    @Published var averageEntryLength: Int = 0
//    @Published var averageEntryTime: Int = 0 // Minuten
//    @Published var journalingDays: [Date] = []
//    @Published var frequentWords: [(word: String, count: Int)] = []
//    
//    private let entryViewModel: EntryViewModel
//    private let translationViewModel: TranslationViewModel
//    
//    init(totalJournalingTime: Int, totalWordCount: Int, totalJournalingDays: Int, averageEntryLength: Int, averageEntryTime: Int, journalingDays: [Date], frequentWords: [(word: String, count: Int)], entryViewModel: EntryViewModel, translationViewModel: TranslationViewModel) {
//        self.totalJournalingTime = totalJournalingTime
//        self.totalWordCount = totalWordCount
//        self.totalJournalingDays = totalJournalingDays
//        self.averageEntryLength = averageEntryLength
//        self.averageEntryTime = averageEntryTime
//        self.journalingDays = journalingDays
//        self.frequentWords = frequentWords
//        self.entryViewModel = entryViewModel
//        self.translationViewModel = translationViewModel
//    }
    
    //    func fetchStatistics() {
    //        let entries = entryRepository.fetchAllEntries()
    //
    //        totalJournalingTime = entries.reduce(0) { $0 + $1.duration }
    //        totalWordCount = entries.reduce(0) { $0 + $1.content.split { $0.isWhitespace || $0.isNewline }.count }
    //        totalJournalingDays = Set(entries.map { Calendar.current.startOfDay(for: $0.date) }).count
    //
    //        if !entries.isEmpty {
    //            averageEntryLength = totalWordCount / entries.count
    //            averageEntryTime = totalJournalingTime / entries.count
    //        }
    //
    //        journalingDays = entries.map { Calendar.current.startOfDay(for: $0.date) }
    //
    //        fetchFrequentWords(from: entries)
    //    }
    //
    //    private func fetchFrequentWords(from entries: [JournalEntry]) {
    //        var wordCounts: [String: Int] = [:]
    //
    //        for entry in entries {
    //            let words = entry.content.lowercased().split { !$0.isLetter }
    //            for word in words {
    //                let stemmedWord = stem(word: String(word)) // Stemming-Algorithmus anwenden
    //                wordCounts[stemmedWord, default: 0] += 1
    //            }
    //        }
    //
    //        let sortedWords = wordCounts.sorted { $0.value > $1.value }.prefix(10)
    //        frequentWords = sortedWords.map { ($0.key, $0.value) }
    //
    //        translateFrequentWords()
    //    }
    //
    //    private func stem(word: String) -> String {
    //        return word // Hier könnte eine Stemmer-Logik eingebaut werden
    //    }
    //
    //    private func translateFrequentWords() {
    //        for (index, word) in frequentWords.enumerated() {
    //            translationService.translate(word.word) { translatedWord in
    //                DispatchQueue.main.async {
    //                    self.frequentWords[index].word = translatedWord
    //                }
    //            }
    //        }
    //    }
}
