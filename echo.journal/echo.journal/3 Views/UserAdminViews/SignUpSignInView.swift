import SwiftUI

struct SignUpSignInView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        ZStack{
            // video background mit overlay
            VideoBackgroundViewRep(videoName: "loginBackground2")
                .overlay {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer().frame(height: 60)
                
                EchoSymbolView(colorManager: colorManager)
                    .frame(width: 130, height: 130)
                    .scaleEffect(0.7)
                
                Text("echo.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    // Hauptüberschrift
                    Text(isRegistering ? "Registrieren" : "Anmelden")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Untertitel
                    Text(isRegistering
                         ? "Registriere Dich mit Mail-Adresse und Passwort."
                         : "Melde Dich mit Mail-Adresse und Passwort an.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Mail-Adresse", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                
                SecureField("Passwort", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // Primärer Button mit dynamischer Hintergrund- und Schriftfarbe
                    Button {
                        Task {
                            if isRegistering {
                                await viewModel.signUp(email: email, password: password)
                            } else {
                                await viewModel.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        Text(isRegistering ? "Registrieren" : "Anmelden")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                    }
                    
                    // 3. Divider mit "ODER" in der Mitte
                    HStack{
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .offset(y: 2)
                            .padding(.leading,8)
                        Text("ODER")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .offset(y: 2)
                            .padding(.trailing,8)
                    }
                    
                    // Wechsel-Button (Zum Login / Zur Registrierung)
                    Button(isRegistering ? "Zum Login" : "Zur Registrierung") {
                        isRegistering.toggle()
                    }
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                }
                
                // Fehlermeldung, falls vorhanden
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .contentShape(Rectangle()) // Macht den gesamten Bereich des main VStack tappable
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    SignUpSignInView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}

