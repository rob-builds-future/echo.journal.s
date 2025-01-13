import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserAuthRepository {
    func signUp(email: String, password: String) async throws -> User {
        // 1. Firebase Auth Account erstellen
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // 2. User mit Default-Username erstellen (aus E-Mail)
        let username = email.split(separator: "@").first ?? "User"
        let user = User(email: email, username: String(username))
        
        // 3. User in Firestore speichern
        try await Firestore.firestore()
            .collection("users")
            .document(authResult.user.uid)
            .setData([
                "id": authResult.user.uid,
                "email": user.email,
                "username": user.username,
                "preferredLanguage": user.preferredLanguage,
                "createdAt": user.createdAt
            ])
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        // 1. Firebase Auth Login
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        // 2. User Daten aus Firestore laden
        let document = try await Firestore.firestore()
            .collection("users")
            .document(authResult.user.uid)
            .getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        return User(
            email: data["email"] as! String,
            username: data["username"] as! String
        )
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        // Hier könnten wir auch Firestore-Daten laden, aber für's erste reicht die E-Mail
        return User(email: firebaseUser.email ?? "", username: "")
    }
}
