import FirebaseFirestore
import FirebaseAuth

class UserStoreRepository {
    func updateUser(id: String, username: String, preferredLanguage: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(id)
            .updateData([
                "username": username,
                "preferredLanguage": preferredLanguage
            ])
    }
    
    func getUser(id: String) async throws -> User? {
        let document = try await Firestore.firestore()
            .collection("users")
            .document(id)
            .getDocument()
        
        guard let data = document.data() else { return nil }
        
        return User(
            email: data["email"] as! String,
            username: data["username"] as! String
        )
    }
    
    func deleteUser(id: String) async throws {
        // 1. User aus Firestore löschen
        try await Firestore.firestore()
            .collection("users")
            .document(id)
            .delete()
        
        // 2. Auth Account löschen
        try await Auth.auth().currentUser?.delete()
    }
}
