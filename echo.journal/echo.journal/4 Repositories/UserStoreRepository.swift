import FirebaseFirestore
import FirebaseAuth

class UserStoreRepository {
    let store = Firestore.firestore()
    
    func createUser(_ user: User) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "preferredLanguage": user.preferredLanguage.rawValue, // Als String, damit Firebase es speichern kann (geht nicht im enum Typ)
                "createdAt": user.createdAt
            ])
    }
    
    func getUser(id: String) async throws -> User? {
        let document = try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .getDocument()
        
        guard let data = document.data() else { return nil }
        
        // Beim Getten: Umwandeln von gespeichertem String in Firebase in Language Format
            let languageString = data["preferredLanguage"] as? String ?? "en" // Default to "en"
            let preferredLanguage = Language(rawValue: languageString) ?? .en // Fallback to .en
        
        return User(
            id: id,
            email: data["email"] as? String ?? "",
            username: data["username"] as? String ?? "",
            preferredLanguage: preferredLanguage // Setze den Language-Enum
        )
    }
    
    func getPreferredLanguage(userId: String) async throws -> Language {
        print("Lade bevorzugte Sprache für User ID: \(userId)")
        let document = try await store.collection("users").document(userId).getDocument()
        
        print("Dokumentdaten: \(document.data() ?? [:])")
        
        guard let data = document.data(),
              let languageString = data["preferredLanguage"] as? String,
              let preferredLanguage = Language(rawValue: languageString) else {
            throw NSError(domain: "UserStoreRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Benutzer oder bevorzugte Sprache nicht gefunden"])
        }
        
        print("Bevorzugte Sprache: \(preferredLanguage.rawValue)")
        return preferredLanguage
    }

    
    
    func updateUser(id: String, username: String, preferredLanguage: Language) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .updateData([
                "username": username,
                "preferredLanguage": preferredLanguage.rawValue // Als String, damit Firebase es speichern kann (geht nicht im enum Typ)
            ])
    }
    
    func deleteUser(id: String) async throws {
        // 1. User aus Firestore löschen
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .delete()
        
        // 2. Auth Account löschen
        try await Auth.auth().currentUser?.delete()
    }
}
