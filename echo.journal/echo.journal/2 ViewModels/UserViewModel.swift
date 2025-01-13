import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authRepository: UserAuthRepository
    private let storeRepository: UserStoreRepository
    
    init(authRepository: UserAuthRepository, storeRepository: UserStoreRepository) {
        self.authRepository = authRepository
        self.storeRepository = storeRepository
        self.currentUser = authRepository.getCurrentUser()
    }
    
    // MARK: - Auth Methods
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await authRepository.signUp(email: email, password: password)
                self.currentUser = user
                self.isLoading = false
            } catch {
                self.errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await authRepository.signIn(email: email, password: password)
                self.currentUser = user
                self.isLoading = false
            } catch {
                self.errorMessage = "Login fehlgeschlagen: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        do {
            try authRepository.signOut()
            currentUser = nil
        } catch {
            errorMessage = "Logout fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User Data Methods
    
    func updateProfile(username: String, preferredLanguage: String) {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        Task {
            do {
                try await storeRepository.updateUser(
                    id: userId,
                    username: username,
                    preferredLanguage: preferredLanguage
                )
                
                // Lade aktualisierten User
                if let updatedUser = try await storeRepository.getUser(id: userId) {
                    self.currentUser = updatedUser
                    self.isLoading = false
                }
            } catch {
                self.errorMessage = "Update fehlgeschlagen: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func deleteAccount() {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        Task {
            do {
                try await storeRepository.deleteUser(id: userId)
                self.currentUser = nil
                self.isLoading = false
            } catch {
                self.errorMessage = "Löschen fehlgeschlagen: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
