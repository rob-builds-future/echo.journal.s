import FirebaseFirestore
import FirebaseAuth

class EntryStoreRepository {
    let store = Firestore.firestore()
    
    /// Erstellt einen neuen Tagebucheintrag für einen Benutzer und speichert ihn in Firestore.
    /// Gibt den erstellten Eintrag mit der generierten Dokument-ID zurück.
    func createEntry(userId: String, content: String, duration: Double, createdAt: Date) async throws -> JournalEntry {
        // 1. Erstelle den Eintrag ohne ID
        var entry = JournalEntry(
            userId: userId,
            content: content,
            duration: duration,
            createdAt: createdAt
        )
        
        let entryData = try Firestore.Encoder().encode(entry)
        
        // 2. Füge den Eintrag hinzu und erhalte die generierte Dokument-ID
        let documentRef = try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .addDocument(data: entryData)
        
        // 3. Setze die generierte Dokument-ID im Eintrag
        entry.id = documentRef.documentID
        
        // 4. Speichere die ID direkt im Firestore-Dokument (optional)
        try await documentRef.updateData(["id": entry.id])
        
        // 5. Gib den aktualisierten Eintrag zurück
        return entry
    }
    
    /// Holt alle Tagebucheinträge eines Benutzers aus Firestore.
    /// Gibt eine Liste von `JournalEntry`-Objekten zurück.
    func getEntries(userId: String) async throws -> [JournalEntry] {
        let snapshot = try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            var entry = try? document.data(as: JournalEntry.self)
            entry?.duration = document.data()["duration"] as? Double ?? 0 // Fallback, falls `duration` fehlt
            return entry
        }
    }
    
    /// Aktualisiert den Inhalt eines bestehenden Tagebucheintrags.
    /// Falls `createdAt` übergeben wird, wird auch das Erstellungsdatum aktualisiert.
    func updateEntry(userId: String, entryId: String, content: String, createdAt: Date? = nil) async throws {
        var entryData: [String: Any] = [
            "content": content,
            "updatedAt": Date() // Aktualisierungszeitpunkt setzen
        ]
        
        if let newCreatedAt = createdAt {
            entryData["createdAt"] = newCreatedAt
        }
        
        try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .document(entryId)
            .updateData(entryData)
    }

    /// Setzt oder entfernt die Favoritenmarkierung (`isFavorite`) eines Eintrags.
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
    
    /// Löscht einen Tagebucheintrag aus Firestore.
    func deleteEntry(userId: String, entryId: String) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(userId)
            .collection("journalEntries")
            .document(entryId)
            .delete()
    }
}
