import Foundation
import Combine

class InspirationViewModel: ObservableObject {
    @Published var inspirations: [Inspiration] = []
    @Published var currentIndex: Int = 0
    
    private var repository: InspirationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Default-Initialisierung mit dem Firebase-Repository
    init(repository: InspirationRepositoryProtocol = InspirationStoreRepository()) {
        self.repository = repository
        fetchInspirations()
    }
    
    /// Lädt alle Inspirations aus dem Repository
    func fetchInspirations() {
        repository.fetchInspirations { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let inspirations):
                    self?.inspirations = inspirations
                    self?.currentIndex = 0
                case .failure(let error):
                    print("Fehler beim Laden der Inspirationen: \(error)")
                }
            }
        }
    }
    
    /// Liefert eine tägliche Inspiration basierend auf dem Tag des Jahres
    func dailyInspiration() -> Inspiration? {
        guard !inspirations.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % inspirations.count
        return inspirations[index]
    }
    
    /// Aktuell ausgewählte Inspiration (für das manuelle Blättern)
    var currentInspiration: Inspiration? {
        guard !inspirations.isEmpty else { return nil }
        return inspirations[currentIndex]
    }
    
    /// Wechselt zur nächsten Inspiration
    func nextInspiration() {
        guard !inspirations.isEmpty else { return }
        currentIndex = (currentIndex + 1) % inspirations.count
    }
}
