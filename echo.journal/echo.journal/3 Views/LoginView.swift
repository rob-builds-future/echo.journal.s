import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    init() {
        let authRepo = UserAuthRepository()
        let storeRepo = UserStoreRepository()
        _viewModel = StateObject(wrappedValue: UserViewModel(
            authRepository: authRepo,
            storeRepository: storeRepo
        ))
    }
    
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
                    if isRegistering {
                        viewModel.signUp(email: email, password: password)
                    } else {
                        viewModel.signIn(email: email, password: password)
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
    LoginView()
}
