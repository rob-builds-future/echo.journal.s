import SwiftUI

struct ContentView: View {
    // ViewModel für die Benutzerverwaltung (Authentifizierung & Datenverwaltung)
    @StateObject private var userViewModel: UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    
    // Farbverwaltung für das Design
    @StateObject private var colorManager = ColorManager()
    
    // Ladezustand für die Ansicht
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            if userViewModel.isLoading {
                // Ladebildschirm anzeigen, während das ViewModel noch lädt
                SplashView(colorManager: colorManager)
            } else if userViewModel.isLoggedIn {
                if !userViewModel.hasCompletedOnboarding {
                    // Zeigt das Onboarding an, falls es noch nicht abgeschlossen wurde
                    OnboardingInfoView(viewModel: userViewModel, colorManager: colorManager)
                } else {
                    // Nach dem Onboarding wird die Hauptansicht mit den Tagebucheinträgen geladen
                    EntryListView(userViewModel: userViewModel, colorManager: colorManager)
                }
            } else {
                // Falls der Benutzer nicht eingeloggt ist, wird die Anmeldeansicht angezeigt
                SignUpSignInView(viewModel: userViewModel, colorManager: colorManager)
            }
        }
        .onAppear {
            // Hier können Aktionen beim ersten Laden der Ansicht erfolgen (falls benötigt)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ColorManager()) // Stellt sicher, dass ColorManager in der Vorschau verfügbar ist
}
