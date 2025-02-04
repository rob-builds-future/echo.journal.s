import FirebaseFirestore

protocol InspirationRepositoryProtocol {
    func fetchInspirations(completion: @escaping (Result<[Inspiration], Error>) -> Void)
}

class InspirationStoreRepository: InspirationRepositoryProtocol {
    private let store = Firestore.firestore()
    
    func fetchInspirations(completion: @escaping (Result<[Inspiration], Error>) -> Void) {
        store.collection("inspirations").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let inspirations = documents.compactMap { doc -> Inspiration? in
                let data = doc.data()
                guard let text = data["text"] as? String else { return nil }
                let author = data["author"] as? String
                return Inspiration(id: doc.documentID, text: text, author: author)
            }
            completion(.success(inspirations))
        }
    }
}
