import Foundation
import Combine
import NaturalLanguage

@MainActor
class StatisticsViewModel: ObservableObject {
    // Bisherige Statistiken
    @Published var totalDuration: Double = 0  // in Minuten
    @Published var totalWords: Int = 0
    
    // Kalender-Properties (wie in der vorherigen Version)
    @Published var displayedMonth: Date = Date()
    
    // Abhängigkeit zu EntryViewModel, um auf die JournalEntries zuzugreifen
    private let entryViewModel: EntryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // Top verwendete Wörter
    @Published var topWords: [(word: String, count: Int)] = []
    
    init(entryViewModel: EntryViewModel) {
        self.entryViewModel = entryViewModel
        
        // Beobachtung der JournalEntries, um Statistiken zu aktualisieren
        entryViewModel.$entries
            .sink { [weak self] entries in
                guard let self = self else { return }
                // Berechnung der Gesamtdauer (hier wird angenommen, dass die Duration in Sekunden gespeichert wurde)
                self.totalDuration = entries.reduce(0) { $0 + $1.duration } / 60
                // Wortanzahl
                self.totalWords = entries.reduce(0) { count, entry in
                    count + entry.content.split { $0.isWhitespace }.count
                }
                // Top Wörter berechnen (hier z.B. Top 30)
                self.topWords = self.calculateTopWords(from: entries, top: 30)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Formatierte Statistiken (wie zuvor)
    var formattedDuration: String {
        let totalMinutes = Int(totalDuration)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours) Stunden \(minutes) Minuten"
    }
    
    var averageDuration: Double {
        let count = entryViewModel.entries.count
        guard count > 0 else { return 0 }
        return totalDuration / Double(count)
    }
    
    var formattedAverageDuration: String {
        let avgMinutes = Int(averageDuration)
        let hours = avgMinutes / 60
        let minutes = avgMinutes % 60
        return "\(hours) Stunden \(minutes) Minuten"
    }
    
    var averageWords: Double {
        let count = entryViewModel.entries.count
        guard count > 0 else { return 0 }
        return Double(totalWords) / Double(count)
    }
    
    /// Gesamtanzahl der Einträge
    var totalEntries: Int {
        entryViewModel.entries.count
    }
    
    // MARK: - Kalenderfunktionen (wie zuvor)
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    var weekdays: [String] {
        var symbols = Calendar.current.shortStandaloneWeekdaySymbols
        let sunday = symbols.remove(at: 0)
        symbols.append(sunday)
        return symbols
    }
    
    func daysForDisplayedMonth() -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var current = firstWeekInterval.start
        let dayCount = 42  // typisches 6x7-Gitter
        for _ in 0..<dayCount {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }
    
    func hasEntry(on date: Date) -> Bool {
        let calendar = Calendar.current
        return entryViewModel.entries.contains { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: date)
        }
    }
    
    func goToPreviousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    func goToNextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    // MARK: - Top Words Ranking
    
    /// Erzeugt ein Ranking der am häufigsten verwendeten Wörter aus den JournalEntries.
    /// Dabei wird NSLinguisticTagger zur Lemmatisierung genutzt, um unterschiedliche Formen
    /// eines Wortes zusammenzuführen.
    func calculateTopWords(from entries: [JournalEntry], top: Int = 30) -> [(word: String, count: Int)] {
        // Alle Inhalte zusammenführen
        let fullText = entries.map { $0.content }.joined(separator: " ")
        
        // Wörter extrahieren und lemmatisieren
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
        tagger.string = fullText
        
        var wordCounts: [String: Int] = [:]
        let range = NSRange(location: 0, length: fullText.utf16.count)
        
        tagger.enumerateTags(in: range,
                             unit: .word,
                             scheme: .lemma,
                             options: [.omitPunctuation, .omitWhitespace, .omitOther]) { tag, tokenRange, _ in
            if let lemma = tag?.rawValue.lowercased() {
                // Erhöhe den Zähler für das lemmatisierte Wort
                wordCounts[lemma, default: 0] += 1
            } else {
                if let tokenRange = Range(tokenRange, in: fullText) {
                    let token = String(fullText[tokenRange]).lowercased()
                    wordCounts[token, default: 0] += 1
                }
            }
        }
        
        // Filtere alle Wörter, die 3 oder weniger Buchstaben haben
        let filteredWords = wordCounts.filter { $0.key.count > 3 }
        
        // Sortieren und Top-N auswählen; umwandeln in das gewünschte Format
        let sortedWords = filteredWords.sorted { $0.value > $1.value }
        return sortedWords.prefix(top).map { (word: $0.key, count: $0.value) }
    }

}
