import SwiftUI

struct ContentView: View {
    // ViewModel für die Benutzerverwaltung (Authentifizierung & Datenverwaltung)
    @StateObject private var viewModel: UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    
    // Farbverwaltung für das Design
    @StateObject private var colorManager = ColorManager()
    
    // Ladezustand für die Ansicht
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                // Ladebildschirm anzeigen, während das ViewModel noch lädt
                SplashView(colorManager: colorManager)
            } else if viewModel.isLoggedIn {
                if !viewModel.hasCompletedOnboarding {
                    // Zeigt das Onboarding an, falls es noch nicht abgeschlossen wurde
                    OnboardingInfoView(viewModel: viewModel, colorManager: colorManager)
                } else {
                    // Nach dem Onboarding wird die Hauptansicht mit den Tagebucheinträgen geladen
                    EntryListView(userViewModel: viewModel, colorManager: colorManager)
                }
            } else {
                // Falls der Benutzer nicht eingeloggt ist, wird die Anmeldeansicht angezeigt
                SignUpSignInView(viewModel: viewModel, colorManager: colorManager)
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
