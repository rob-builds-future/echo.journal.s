import SwiftUI

struct EntryListView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        VStack {
            // Hole den aktuellen Benutzer aus dem ViewModel
            if let user = viewModel.currentUser {
                Text("Willkommen, \(user.username)!")
                    .font(.largeTitle)
                    .padding()
                Text("Deine Zielsprache ist \(user.preferredLanguage.rawValue)!")
                    .font(.footnote)
                    .padding()
            } else {
                Text("Willkommen!")
                    .font(.largeTitle)
                    .padding()
            }

            NavigationLink(destination: EntryView(viewModel: viewModel)) {
                Text("Neuen Eintrag erstellen")
            }
            .buttonStyle(.bordered)

            NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                Text("Einstellungen")
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("\(viewModel.currentUser?.username ?? "")'s Tagebuch") // Setze den Titel der Navigation
    }
}

#Preview {
    EntryListView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}
