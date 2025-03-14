import Foundation
import FirebaseAuth

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var user: FirebaseAuth.User?
    @Published var hasCompletedOnboarding = false
    
    let authRepository: UserAuthRepository
    let storeRepository: UserStoreRepository
    
    // MARK: - Lifecycle/Initializer
    
    init(authRepository: UserAuthRepository, storeRepository: UserStoreRepository) {
        self.authRepository = authRepository
        self.storeRepository = storeRepository
        
        startVM()
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
            
            // 4. Onboarding-Status in UserDefaults initialisieren
            let onboardingKey = "hasCompletedOnboarding_\(user.id)"
            UserDefaults.standard.set(false, forKey: onboardingKey)
            self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
            
        } catch {
            self.errorMessage = String(format: NSLocalizedString("signUpError", comment: ""), error.localizedDescription)
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
            
            let onboardingKey = "hasCompletedOnboarding_\(user.id)"
            self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
            
            self.isLoggedIn = true // Setze isLoggedIn auf true
            
        } catch {
            self.errorMessage = "Login fehlgeschlagen: \(error.localizedDescription)"
            self.errorMessage = String(format: NSLocalizedString("signInError", comment: ""), error.localizedDescription)
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
    
    // MARK: - Onboarding Methods
    
    func updateOnboardingStatus() {
        guard let userId = currentUser?.id else { return } // Stelle sicher, dass ein Benutzer angemeldet ist
        
        let onboardingKey = "hasCompletedOnboarding_\(userId)"
        
        // Speichere den Status benutzerspezifisch
        UserDefaults.standard.set(true, forKey: onboardingKey)
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func startVM() {
        Task {
            let minimumLoadingTime: UInt64 = 3_000_000_000 // 3 Sekunden in Nanosekunden
            let startTime = DispatchTime.now() // Startzeit des Ladevorgangs
            
            do {
                // 1. Benutzer aus AuthRepository laden
                if let user = try await authRepository.getCurrentUser() {
                    currentUser = user
                    isLoggedIn = true
                        // 2. Onboarding-Status des Benutzers laden
                        let userId = user.id
                        let onboardingKey = "hasCompletedOnboarding_\(userId)"
                        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
                }
            } catch {
                errorMessage = "Fehler beim Abrufen des aktuellen Benutzers: \(error.localizedDescription)"
            }
            
            // Berechne verbleibende Zeit, um die Mindestladezeit einzuhalten
            let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
            let remainingTime = minimumLoadingTime > elapsedTime ? minimumLoadingTime - elapsedTime : 0
            try? await Task.sleep(nanoseconds: remainingTime)
            
            isLoading = false // Ladezustand beenden
        }
    }
}
