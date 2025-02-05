import Foundation

@MainActor
class EntryViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isSaving = false // Zustandsvariable zum Verhindern von Mehrfachklicks
    
    private let entryStoreRepository: EntryStoreRepository
    private let userId: String // Benutzer-ID, um Einträge zuzuordnen
    
    // Start- und Endzeit für das Schreiben eines Eintrags
    private var startTime: Date?
    private var stopTime: Date?
    
    init(entryStoreRepository: EntryStoreRepository, userId: String) {
        self.entryStoreRepository = entryStoreRepository
        self.userId = userId
    }
    
    // MARK: - Zeitmessung
    
    func startTimer(content: String) {
        if startTime == nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            startTime = Date()
        }
    }
    
    func stopTimer(content: String) {
        if startTime != nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            stopTime = Date()
        }
    }
    
    func getDuration() -> TimeInterval {
        guard let startTime, let stopTime else { return 0 }
        return startTime.distance(to: stopTime)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
           let minutes = max(Int(duration / 60), 1) // Mindestens 1 Minute
           return "\(minutes)"
       }
    
    // MARK: - CRUD Methoden
    
    func createEntry(content: String, date: Date) async throws {
        guard !isSaving else { return } // Verhindere Mehrfachklicks
        isSaving = true
        errorMessage = nil
        
        defer {
            isSaving = false // Reset nach Abschluss
        }
        
        stopTimer(content: content) // ⏱ Stoppe den Timer
        let duration = getDuration() // ⏱ Berechne die Dauer

        do {
            let newEntry = try await entryStoreRepository.createEntry(
                userId: userId,
                content: content,
                duration: duration,
                createdAt: date // ✅ Speichert das gewählte Datum
            )
            entries.append(newEntry) // Neuen Eintrag zur Liste hinzufügen
        } catch {
            errorMessage = "Fehler beim Erstellen des Eintrags: \(error.localizedDescription)"
            throw error
        }
    }

    
    /// Formatiert das Erstellungsdatum
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func loadEntries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            entries = try await entryStoreRepository.getEntries(userId: userId)
        } catch {
            errorMessage = "Fehler beim Laden der Einträge: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateEntry(entryId: String, content: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await entryStoreRepository.updateEntry(userId: userId, entryId: entryId, content: content)
            if let index = entries.firstIndex(where: { $0.id == entryId }) {
                entries[index].content = content // Aktualisiere den Eintrag in der Liste
                entries[index].updatedAt = Date() // Aktualisiere das Datum
            }
        } catch {
            errorMessage = "Fehler beim Aktualisieren des Eintrags: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleFavorite(entryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await entryStoreRepository.toggleFavorite(userId: userId, entryId: entryId)
            if let index = entries.firstIndex(where: { $0.id == entryId }) {
                entries[index].isFavorite.toggle() // Aktualisiere den Favoritenstatus in der Liste
            }
        } catch {
            errorMessage = "Fehler beim Ändern des Favoritenstatus: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteEntry(entryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await entryStoreRepository.deleteEntry(userId: userId, entryId: entryId)
            entries.removeAll { $0.id == entryId } // Entferne den Eintrag aus der Liste
        } catch {
            errorMessage = "Fehler beim Löschen des Eintrags: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
