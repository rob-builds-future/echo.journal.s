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
            if viewModel.isLoading {
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
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ColorManager()) // ColorManager explizit bereitstellen
}
