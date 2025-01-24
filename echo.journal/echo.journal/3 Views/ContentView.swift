import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel : UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    @StateObject private var colorManager = ColorManager()
    
    @State private var isLoading: Bool = true // Ladezustand
    
    var body: some View {
        NavigationStack {
            if isLoading {
                SplashView(colorManager: colorManager) // Ladebildschirm anzeigen, solange isLoading true ist
            } else if viewModel.isLoggedIn {
                if !viewModel.hasCompletedOnboarding {
                    OnboardingInfoView(viewModel: viewModel, colorManager: colorManager) // Zeige Onboarding, wenn nicht abgeschlossen
                } else {
                    EntryListView(userViewModel: viewModel, colorManager: colorManager) // Hauptansicht nach Onboarding
                }
            } else {
                SignUpSignInView(viewModel: viewModel, colorManager: colorManager)
            }
            
        }
        .onAppear {
            Task {
                let minimumLoadingTime: UInt64 = 3_000_000_000 // 1 Sekunde in Nanosekunden
                let startTime = DispatchTime.now() // Startzeit des Ladevorgangs
                
                do {
                    // 1. Benutzer aus AuthRepository laden
                    if let user = try await viewModel.authRepository.getCurrentUser() {
                        viewModel.currentUser = user
                        viewModel.isLoggedIn = true
                        
                        // 2. Onboarding-Status des Benutzers laden
                        let userId = user.id
                        let onboardingKey = "hasCompletedOnboarding_\(userId)"
                        viewModel.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
                    }
                } catch {
                    viewModel.errorMessage = "Fehler beim Abrufen des aktuellen Benutzers: \(error.localizedDescription)"
                }
                
                // Berechne verbleibende Zeit, um die Mindestladezeit einzuhalten
                let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                let remainingTime = minimumLoadingTime > elapsedTime ? minimumLoadingTime - elapsedTime : 0
                try? await Task.sleep(nanoseconds: remainingTime)
                
                isLoading = false // Ladezustand beenden
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ColorManager()) // ColorManager explizit bereitstellen
}
