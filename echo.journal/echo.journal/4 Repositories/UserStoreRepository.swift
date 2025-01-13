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
                "preferredLanguage": user.preferredLanguage,
                "createdAt": user.createdAt
            ])
    }
    
    func getUser(id: String) async throws -> User? {
        let document = try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .getDocument()
        
        guard let data = document.data() else { return nil }
        
        return User(
            id: id,
            email: data["email"] as? String ?? "",
            username: data["username"] as? String ?? ""
        )
    }
    
    func updateUser(id: String, username: String, preferredLanguage: String) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .updateData([
                "username": username,
                "preferredLanguage": preferredLanguage
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
