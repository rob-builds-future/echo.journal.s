import FirebaseFirestore
import FirebaseAuth

class UserStoreRepository {
    let store = Firestore.firestore()

    // Erstellt einen neuen Benutzer in Firestore.
    func createUser(_ user: User) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "preferredLanguage": user.preferredLanguage.rawValue, // Enum-Wert als String speichern
                "createdAt": user.createdAt
            ])
    }

    // Holt einen Benutzer aus Firestore anhand der ID.
    // Gibt `nil` zurück, falls der Benutzer nicht existiert.
    func getUser(id: String) async throws -> User? {
        let document = try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .getDocument()
        
        guard let data = document.data() else { return nil }
        
        // Sprache aus Firestore-Daten laden und in den Enum umwandeln
        let languageString = data["preferredLanguage"] as? String ?? "en"
        let preferredLanguage = Language(rawValue: languageString) ?? .en
        
        return User(
            id: id,
            email: data["email"] as? String ?? "",
            username: data["username"] as? String ?? "",
            preferredLanguage: preferredLanguage,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    // Holt die bevorzugte Sprache eines Benutzers aus Firestore.
    func getPreferredLanguage(userId: String) async throws -> Language {
        print("Lade bevorzugte Sprache für User ID: \(userId)")
        let document = try await store.collection("users").document(userId).getDocument()
        
        print("Dokumentdaten: \(document.data() ?? [:])")
        
        guard let data = document.data(),
              let languageString = data["preferredLanguage"] as? String,
              let preferredLanguage = Language(rawValue: languageString) else {
            throw NSError(domain: "UserStoreRepository", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Benutzer oder bevorzugte Sprache nicht gefunden"
            ])
        }
        
        print("Bevorzugte Sprache: \(preferredLanguage.rawValue)")
        return preferredLanguage
    }

    // Aktualisiert den Benutzernamen und die bevorzugte Sprache in Firestore.
    func updateUser(id: String, username: String, preferredLanguage: Language) async throws {
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .updateData([
                "username": username,
                "preferredLanguage": preferredLanguage.rawValue // Enum-Wert als String speichern
            ])
    }

    // Löscht einen Benutzer aus Firestore und entfernt das zugehörige Auth-Konto.
    func deleteUser(id: String) async throws {
        // 1. Benutzer aus Firestore entfernen
        try await store.collection(DocumentPath.users.rawValue)
            .document(id)
            .delete()
        
        // 2. Firebase Auth-Konto löschen (falls angemeldet)
        try await Auth.auth().currentUser?.delete()
    }
}
