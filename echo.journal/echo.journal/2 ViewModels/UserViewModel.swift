import Foundation
import FirebaseAuth

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var user: FirebaseAuth.User?
    
    let authRepository: UserAuthRepository
    let storeRepository: UserStoreRepository
    
    // MARK: - Lifecycle/Initializer
    init(authRepository: UserAuthRepository, storeRepository: UserStoreRepository) {
        self.authRepository = authRepository
        self.storeRepository = storeRepository
        
    }
    
    // MARK: - Auth Methods
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. User bei Auth registrieren
            let user = try await authRepository.signUp(email: email, password: password)
            
            // 2. User in Firestore speichern
            try await storeRepository.createUser(user)
            
            // 3. UI aktualisieren
            self.currentUser = user
            self.isLoggedIn = true // Setze isLoggedIn auf true
        } catch {
            self.errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. User bei Auth einloggen
            let user = try await authRepository.signIn(email: email, password: password)
            
            // 2. User-Daten aus Firestore laden
            if let storedUser = try await storeRepository.getUser(id: user.id) {
                self.currentUser = storedUser
            } else {
                self.currentUser = user
            }
            
            self.isLoggedIn = true // Setze isLoggedIn auf true
            
        } catch {
            self.errorMessage = "Login fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try authRepository.signOut()
            currentUser = nil
            isLoggedIn = false // Setze isLoggedIn auf false
        } catch {
            errorMessage = "Logout fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User Data Methods
    
    func updateProfile(username: String, preferredLanguage: Language) async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        do {
            try await storeRepository.updateUser(
                id: userId,
                username: username,
                preferredLanguage: preferredLanguage
            )
            
            // Lade aktualisierten User
            if let updatedUser = try await storeRepository.getUser(id: userId) {
                self.currentUser = updatedUser
            }
        } catch {
            self.errorMessage = "Update fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        do {
            try await storeRepository.deleteUser(id: userId)
            try authRepository.signOut()
            self.currentUser = nil
            self.isLoggedIn = false // Setze isLoggedIn auf false
        } catch {
            self.errorMessage = "Löschen fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
