import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "Registrieren" : "Login")
                .font(.title)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Passwort", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                Button(isRegistering ? "Registrieren" : "Login") {
                    Task {
                        if isRegistering {
                            await viewModel.signUp(email: email, password: password)
                        } else {
                            await viewModel.signIn(email: email, password: password)
                        }
                        // Überprüfe, ob der Benutzer erfolgreich eingeloggt ist
                        //if viewModel.currentUser != nil {
                        //    isLoggedIn = true // Setze den Zustand für die Navigation
                        //}
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button(isRegistering ? "Zum Login" : "Zur Registrierung") {
                    isRegistering.toggle()
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}

