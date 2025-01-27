import SwiftUI
import FirebaseAuth

struct PreferredLanguageTestView: View {
   
    @State private var preferredLanguage: String = "Lädt..."
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Fehler: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Bevorzugte Sprache: \(preferredLanguage)")
                    .font(.headline)
            }
        }
        .onAppear {
            Task {
                do {
                    guard let currentUser = Auth.auth().currentUser else {
                        errorMessage = "Kein authentifizierter Benutzer."
                        return
                    }
                    
                    let repository = UserStoreRepository()
                    let language = try await repository.getPreferredLanguage(userId: currentUser.uid)
                    preferredLanguage = language.rawValue
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    PreferredLanguageTestView()
}
