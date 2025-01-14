import FirebaseAuth

class UserAuthRepository {
    let auth = Auth.auth()
    
    
    func signUp(email: String, password: String) async throws -> User {
        do {
            // 1. Firebase Auth User erstellen
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            // 2. Eigene User Model Instanz erstellen
            let username = email.split(separator: "@").first ?? "User"
            let user = User(
                id: firebaseUser.uid,
                email: email,
                username: String(username),
                preferredLanguage: .en
            )
            
            return user
        } catch {
            print("SignUp Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            // 1. Firebase Auth Login
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            // 2. Hole die Benutzerdaten aus Firestore
            let userStoreRepository = UserStoreRepository()
            if let user = try await userStoreRepository.getUser(id: firebaseUser.uid) {
                return user // Gibt den Benutzer mit den vollständigen Daten zurück
            } else {
                throw NSError(domain: "UserAuthRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
        } catch {
            print("SignIn Error: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            print(error)
            throw error
        }
    }
    
    func getCurrentUser() async throws -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        let userStoreRepository = UserStoreRepository()
        return try await userStoreRepository.getUser(id: firebaseUser.uid) // Hole die Benutzerdaten aus Firestore
    }
}
