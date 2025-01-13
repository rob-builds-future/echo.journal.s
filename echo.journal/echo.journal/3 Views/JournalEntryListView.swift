import SwiftUI

struct JournalEntryListView: View {
    @ObservedObject var viewModel: UserViewModel
    var user: User
    
    var body: some View {
        VStack {
            Text("Willkommen, \(user.username)!")
                .font(.largeTitle)
                .padding()
            
            // Logout Button
            Button("Logout") {
                Task {
                    viewModel.signOut() // Logout-Logik aufrufen
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Home") // Setze den Titel der Navigation
    }
}

