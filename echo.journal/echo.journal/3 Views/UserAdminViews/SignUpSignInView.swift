import SwiftUI

struct SignUpSignInView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        
        ZStack{
            // Add video background mit overlay
            VideoBackgroundView(videoName: "loginBackground2")
                .overlay {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                }
            VStack(spacing: 20) {
                
                Spacer().frame(height: 60)
                
                EchoSymbolView()
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
//                    .keyboardType(.emailAddress)
//                    .toolbar {
//                        // 2) Mit .keyboard platzierst du die Toolbar direkt über der Tastatur
//                        ToolbarItemGroup(placement: .keyboard) {
//                            Spacer()
//                            Button {
//                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                                                to: nil,
//                                                                from: nil,
//                                                                for: nil)
//                            } label: {
//                                // 3) Tastatursymbol (SF Symbol)
//                                Image(systemName: "keyboard.chevron.compact.down")
//                            }
//                            .padding(.trailing, 8)
//                        }
//                    }
                
                SecureField("Passwort", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // 2. Primärer Button mit dynamischer Hintergrund- und Schriftfarbe
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
                        // Schriftfarbe abhängig vom Mode (weiß/schwarz)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        // Hintergrund abhängig vom Mode (weiß/schwarz)
                            .background(colorScheme == .light ? Color.white : Color.black)
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
            .padding()
        }
    }
}

#Preview {
    SignUpSignInView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}

