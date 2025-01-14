import SwiftUI

struct EntryView: View {
    @ObservedObject var viewModel: UserViewModel
    var entry: JournalEntry? // Optional, um einen bestehenden Eintrag zu bearbeiten

    @State private var content: String = ""

    var body: some View {
        VStack {
            TextField("Inhalt", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(entry == nil ? "Eintrag erstellen" : "Eintrag aktualisieren") {
                // Logik zum Erstellen oder Aktualisieren des Eintrags
                if let entry = entry {
                    // Update Logik
                } else {
                    // Create Logik
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle(entry == nil ? "Neuer Eintrag" : "Eintrag bearbeiten")
    }
}

#Preview {
    EntryView(viewModel:
                UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}
