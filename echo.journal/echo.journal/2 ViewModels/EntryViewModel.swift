import Foundation

@MainActor
class EntryViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedEntry: JournalEntry?
    @Published var isSaving = false // Zustandsvariable zum Verhindern von Mehrfachklicks
    
    private let entryStoreRepository: EntryStoreRepository
    private let userId: String // Benutzer-ID, um Einträge zuzuordnen
    
    init(entryStoreRepository: EntryStoreRepository, userId: String) {
        self.entryStoreRepository = entryStoreRepository
        self.userId = userId
    }
    
    // MARK: - CRUD Methods
    
    func createEntry(content: String) async throws {
        guard !isSaving else { return } // Verhindere Mehrfachklicks
        isSaving = true
        errorMessage = nil
        
        defer {
            isSaving = false // Reset nach Abschluss
        }
        
        do {
            let newEntry = try await entryStoreRepository.createEntry(userId: userId, content: content)
            entries.append(newEntry) // Neuen Eintrag zur Liste hinzufügen
        } catch {
            errorMessage = "Fehler beim Erstellen des Eintrags: \(error.localizedDescription)"
            throw error
        }
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
