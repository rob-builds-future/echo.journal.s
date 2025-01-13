import FirebaseAuth

class UserAuthRepository {
    private var auth = Auth.auth()
    
    
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
                username: String(username)
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
            
            // 2. Unser User Model erstellen
            return User(
                id: firebaseUser.uid,  // Wichtig: Firebase UID als ID der eigenen User Model Instanz verwenden
                email: firebaseUser.email ?? "",
                username: "" // Wird später aus Firestore geladen
            )
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
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        // Hier könnten wir auch Firestore-Daten laden, aber für's erste reicht die E-Mail
        return User(id: firebaseUser.uid, email: firebaseUser.email ?? "", username: "")
    }
}
