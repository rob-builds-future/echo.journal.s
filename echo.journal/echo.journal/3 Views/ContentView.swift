import SwiftUI

struct ContentView: View {
    // ViewModel für die Benutzerverwaltung (Authentifizierung & Datenverwaltung)
    @StateObject private var userViewModel: UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    
    // Farbverwaltung für das Design
    @StateObject private var colorManager = ColorManager()
    
    // Path für sauberes Navigieren aus Onboarding
    @State private var navigationPath: [String] = []
    
    var body: some View {
        NavigationStack {
            if userViewModel.isLoading {
                // Ladebildschirm anzeigen, während das ViewModel noch lädt
                SplashView(colorManager: colorManager)
            } else if userViewModel.isLoggedIn {
                // Falls der Benutzer eingeloggt ist, zeigen wir den Inhalt
                if !userViewModel.hasCompletedOnboarding {
                    OnboardingInfoView(viewModel: userViewModel, colorManager: colorManager)
                } else {
                    EntryListView(userViewModel: userViewModel, colorManager: colorManager)
                }
            } else {
                // Falls der Benutzer nicht eingeloggt ist, wird die Anmeldeansicht angezeigt
                SignUpSignInView(viewModel: userViewModel, colorManager: colorManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ColorManager()) // Stellt sicher, dass ColorManager in der Vorschau verfügbar ist
}
