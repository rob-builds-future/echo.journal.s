import SwiftUI

struct OnboardingUserDataView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var username: String = ""
    @State private var selectedLanguage: Language = .en // Standardwert
    @State private var selectedColorScheme: String = "AzulLuminoso" // Standardfarbe
    
    var body: some View {
        VStack(spacing: 16) {
            // Sprechblase oben
            SpeechBubbleView(
                text: "Hallo!\nBevor es mit dem Schreiben und Lernen los geht, lass uns Dein Tagebuch auf Dich anpassen.\nBitte wähle als erstes Deinen Nutzernamen, die Sprache, in die echo. deine Tagebucheinträge übersetzt, und die Farbe Deines echo.!",
                backgroundColor: colorManager.currentColor
            )
            .padding(.horizontal)
            
            // Fixe Liste
            List {
                // Nutzernamen-Eingabe
                Section(
                    header: Text("Dein Nutzername")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                ) {
                    TextField("Nutzername", text: $username)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding()
                        .background(Color.clear)
                }
                // Sprache auswählen
                Section(
                    header: Text("Sprache Deines echo.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                ) {
                    Picker("Wähle eine Sprache", selection: $selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(4)
                }
                // Farbschema auswählen
                Section(
                    header: Text("Farbe Deines echo.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                ) {
                    Picker("Wähle eine Farbe", selection: $selectedColorScheme) {
                        Text("Azul Luminoso").tag("AzulLuminoso")
                        Text("Amber Blaze").tag("AmberBlaze")
                        Text("Emerald Teal").tag("EmeraldTeal")
                        Text("Vintage Purple").tag("VintagePurple")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(4)
                }
            }
            .listStyle(.inset)
            .frame(maxHeight: .infinity)
            
            // Fertig-Button bleibt fix unten
            Button("Fertig") {
                Task {
                    await viewModel.updateProfile(username: username, preferredLanguage: selectedLanguage)
                    colorManager.updateColor(to: selectedColorScheme)
                    viewModel.updateOnboardingStatus() // Onboarding als abgeschlossen markieren
                    DispatchQueue.main.async {
                        dismiss() // Schließe die View sicher
                    }
                }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(colorScheme == .dark ? .white : .black)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // View ignoriert Keyboard, keine Verschiebung
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Klick ausßerhalb von keyboard dismissed keyboard
        }
    }
}

#Preview {
    OnboardingUserDataView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
