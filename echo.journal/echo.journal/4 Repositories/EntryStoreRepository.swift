import FirebaseFirestore
import FirebaseAuth

class EntryStoreRepository {
    let store = Firestore.firestore()
    
    // Erstelle einen neuen Tagebucheintrag für einen Benutzer
    func createEntry(userId: String, content: String) async throws -> JournalEntry {
        // 1. Erstelle den Eintrag ohne ID
        var entry = JournalEntry(userId: userId, content: content)
        let entryData = try Firestore.Encoder().encode(entry)

        // 2. Füge den Eintrag hinzu und erhalte die generierte Dokument-ID
        let documentRef = try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .addDocument(data: entryData)

        // 3. Setze die generierte Dokument-ID im Eintrag
        entry.id = documentRef.documentID

        // 4. Aktualisiere das Firestore-Dokument mit der ID (optional, falls du die ID speichern möchtest)
        try await documentRef.updateData(["id": entry.id])

        // 5. Gib den aktualisierten Eintrag zurück
        return entry
    }
    
    // Hole alle Tagebucheinträge
    func getEntries(userId: String) async throws -> [JournalEntry] {
        let snapshot = try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries") // Nested Unterkollektion für die Tagebucheinträge
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: JournalEntry.self)
        }
    }
    
    /* Hole einen spezifischen Tagebucheintrag
    func getEntry(userId: String, entryId: String) async throws -> JournalEntry? {
        let document = try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries") // Nested Unterkollektion für die Tagebucheinträge
            .document(entryId)
            .getDocument()
        
        return try document.data(as: JournalEntry.self)
    }*/
    
    // Aktualisiere einen Tagebucheintrag
    func updateEntry(userId: String, entryId: String, content: String) async throws {
        let entryData: [String: Any] = [
            "content": content,
            "updatedAt": Date() // Aktualisiere das Datum
        ]
        try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries") // Nested Unterkollektion für die Tagebucheinträge
            .document(entryId)
            .updateData(entryData)
    }
    
    // Füge diese Methode in EntryStoreRepository.swift hinzu
    func toggleFavorite(userId: String, entryId: String) async throws {
        let documentRef = store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .document(entryId)
        
        let document = try await documentRef.getDocument()
        guard let isFavorite = document.data()?["isFavorite"] as? Bool else { return }
        
        let newFavoriteStatus = !isFavorite
        try await documentRef.updateData(["isFavorite": newFavoriteStatus])
    }
    
    // Lösche einen Tagebucheintrag
    func deleteEntry(userId: String, entryId: String) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries") // Unterkollektion für die Tagebucheinträge
            .document(entryId)
            .delete()
    }
}
