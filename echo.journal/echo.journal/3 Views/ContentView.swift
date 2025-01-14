import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel : UserViewModel = UserViewModel(
        authRepository: .init(),
        storeRepository: .init()
    )
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoggedIn {
                EntryListView(viewModel: viewModel)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                do {
                    if let user = try await viewModel.authRepository.getCurrentUser() {
                        viewModel.currentUser = user
                        viewModel.isLoggedIn = true // Setze isLoggedIn auf true, wenn der Benutzer vorhanden ist
                    }
                } catch {
                    viewModel.errorMessage = "Fehler beim Abrufen des aktuellen Benutzers: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
