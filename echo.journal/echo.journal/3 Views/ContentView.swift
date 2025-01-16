import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel : UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    @State private var isLoading: Bool = true // Ladezustand
    
    var body: some View {
        NavigationStack {
            if isLoading {
                SplashView() // Ladebildschirm anzeigen, solange isLoading true ist
            } else if viewModel.isLoggedIn {
                EntryListView(viewModel: viewModel)
            } else {
                SignUpSignInView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                let minimumLoadingTime: UInt64 = 3_000_000_000 // 1 Sekunde in Nanosekunden
                let startTime = DispatchTime.now() // Startzeit des Ladevorgangs
                
                do {
                    if let user = try await viewModel.authRepository.getCurrentUser() {
                        viewModel.currentUser = user
                        viewModel.isLoggedIn = true
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
