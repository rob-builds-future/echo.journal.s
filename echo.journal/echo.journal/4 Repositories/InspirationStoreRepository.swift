import FirebaseFirestore

/// Protokoll für das Abrufen von Inspirationen.
protocol InspirationRepositoryProtocol {
    func fetchInspirations(completion: @escaping (Result<[Inspiration], Error>) -> Void)
}

class InspirationStoreRepository: InspirationRepositoryProtocol {
    private let store = Firestore.firestore()
    
    /// Ruft eine Liste von Inspirationen aus Firestore ab.
    /// Gibt das Ergebnis über einen `completion`-Handler zurück.
    func fetchInspirations(completion: @escaping (Result<[Inspiration], Error>) -> Void) {
        store.collection("inspirations").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error)) // Fehler weitergeben
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([])) // Falls keine Dokumente vorhanden sind, leere Liste zurückgeben
                return
            }
            
            // Dokumente in `Inspiration`-Modelle umwandeln
            let inspirations = documents.compactMap { doc -> Inspiration? in
                let data = doc.data()
                guard let text = data["text"] as? String else { return nil } // `text` ist erforderlich
                let author = data["author"] as? String // `author` ist optional
                return Inspiration(id: doc.documentID, text: text, author: author)
            }
            completion(.success(inspirations))
        }
    }
}
