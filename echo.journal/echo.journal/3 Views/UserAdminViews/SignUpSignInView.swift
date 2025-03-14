import SwiftUI

struct SignUpSignInView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme // Ermittelt das aktuelle Farbschema (Hell/Dunkel)
    
    @State private var email = ""       // Eingegebene E-Mail-Adresse
    @State private var password = ""    // Eingegebenes Passwort
    @State private var isRegistering = false // Umschalter für Login oder Registrierung
    
    var body: some View {
        ZStack {
            // Hintergrundvideo mit dunklem Overlay
            VideoBackgroundViewRep(videoName: "loginBackground2")
                .overlay {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer().frame(height: 60)
                
                // Logo (Echo-Symbol)
                EchoSymbolView(colorManager: colorManager)
                    .frame(width: 130, height: 130)
                    .scaleEffect(0.7)
                
                // App-Name
                Text("echo.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    // Hauptüberschrift (Anmelden / Registrieren)
                    Text(isRegistering
                         ? "signUp"
                         : "signIn")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Untertitel
                    Text(isRegistering
                         ? "signUpInstructions"
                         : "signInInstructions")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Eingabefeld für E-Mail
                TextField("emailAddress", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                
                // Eingabefeld für Passwort
                SecureField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if viewModel.isLoading {
                    // Ladeindikator während der Authentifizierung
                    ProgressView()
                } else {
                    // Primärer Button für Anmeldung oder Registrierung
                    Button {
                        Task {
                            if isRegistering {
                                await viewModel.signUp(email: email, password: password)
                            } else {
                                await viewModel.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        Text(isRegistering
                             ? "signUp"
                             : "signIn")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                    }
                    
                    // Visueller Divider mit "ODER" in der Mitte
                    HStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .offset(y: 2)
                            .padding(.leading, 8)
                        
                        Text("or")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .offset(y: 2)
                            .padding(.trailing, 8)
                    }
                    
                    // Umschalter zwischen Anmeldung und Registrierung
                    Button(isRegistering
                           ? "toSignIn"
                           : "toSignUp") {
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
        .contentShape(Rectangle()) // Macht den gesamten Bereich tappable
        .onTapGesture {
            // Blendet die Tastatur aus, wenn außerhalb getippt wird
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
