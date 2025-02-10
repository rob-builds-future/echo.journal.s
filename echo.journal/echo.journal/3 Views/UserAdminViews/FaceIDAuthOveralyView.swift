//import SwiftUI
//import LocalAuthentication
//
//struct FaceIDAuthOverlayView: View {
//    @Binding var isAuthenticated: Bool
//    @State private var authMessage: String = "Bitte authentifizieren Sie sich, um die App zu entsperren."
//    
//    var body: some View {
//        ZStack {
//            Color(.systemBackground)
//                .opacity(0.8)
//                .ignoresSafeArea()
//            VStack(spacing: 20) {
//                Image(systemName: "faceid")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                Text(authMessage)
//                    .multilineTextAlignment(.center)
//                    .padding()
//            }
//        }
//        .onAppear(perform: authenticate)
//    }
//    
//    private func authenticate() {
//        let context = LAContext()
//        var error: NSError?
//        
//        // Prüfen, ob biometrische Authentifizierung verfügbar ist
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Bitte authentifizieren Sie sich, um die App zu entsperren."
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluationError in
//                DispatchQueue.main.async {
//                    if success {
//                        // Authentifizierung erfolgreich
//                        isAuthenticated = true
//                    } else {
//                        // Authentifizierung fehlgeschlagen
//                        authMessage = "Authentifizierung fehlgeschlagen. Bitte versuchen Sie es erneut."
//                    }
//                }
//            }
//        } else {
//            // Falls keine biometrische Authentifizierung möglich ist, können Sie alternativ einen PIN-Code oder andere Logik anbieten.
//            DispatchQueue.main.async {
//                authMessage = "Biometrische Authentifizierung ist nicht verfügbar."
//            }
//        }
//    }
//}
