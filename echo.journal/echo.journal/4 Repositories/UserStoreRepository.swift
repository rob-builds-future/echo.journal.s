import FirebaseFirestore
import FirebaseAuth

class UserStoreRepository {
    private var store = Firestore.firestore()
    
    func createUser(_ user: User) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "preferredLanguage": user.preferredLanguage.rawValue, // Als String, damit Firebase es speichern kann (geht nich im enum typ)
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
    
    func updateUser(id: String, username: String, preferredLanguage: Language) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .updateData([
                "username": username,
                "preferredLanguage": preferredLanguage.rawValue // Als String, damit Firebase es speichern kann (geht nich im enum typ)
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
