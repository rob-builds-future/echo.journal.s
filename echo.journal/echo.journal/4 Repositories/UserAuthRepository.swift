import FirebaseAuth

class UserAuthRepository {
    let auth = Auth.auth()

    // Registriert einen neuen Benutzer mit E-Mail und Passwort.
    // Erstellt anschließend eine User-Instanz mit Standardwerten.
    func signUp(email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            // Benutzername aus der E-Mail generieren (vor '@')
            let username = email.split(separator: "@").first ?? "User"
            
            return User(
                id: firebaseUser.uid,
                email: email,
                username: String(username),
                preferredLanguage: .en,
                createdAt: Date()
            )
        } catch {
            print("SignUp Error: \(error.localizedDescription)")
            throw error
        }
    }

    // Meldet einen Benutzer mit E-Mail und Passwort an.
    // Ruft nach erfolgreicher Authentifizierung die Benutzerdaten aus Firestore ab.
    func signIn(email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            let userStoreRepository = UserStoreRepository()
            
            // Benutzer aus Firestore abrufen, wenn vorhanden
            if let user = try await userStoreRepository.getUser(id: firebaseUser.uid) {
                return user
            } else {
                throw NSError(domain: "UserAuthRepository", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "User not found"
                ])
            }
        } catch {
            print("SignIn Error: \(error.localizedDescription)")
            throw error
        }
    }

    /// Meldet den aktuellen Benutzer ab.
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            print(error)
            throw error
        }
    }

    // Gibt den aktuell angemeldeten Benutzer zurück, falls vorhanden.
    // Holt die vollständigen Benutzerdaten aus Firestore.
    func getCurrentUser() async throws -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        
        let userStoreRepository = UserStoreRepository()
        return try await userStoreRepository.getUser(id: firebaseUser.uid)
    }
}
