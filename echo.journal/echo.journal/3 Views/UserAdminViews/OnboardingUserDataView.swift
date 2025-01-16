import SwiftUI

struct OnboardingUserDataView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager // Zugriff auf den ColorManager
    @State private var username: String = ""
    @State private var selectedLanguage: Language = .en // Standardwert
    @State private var selectedColorScheme: String = "AzulLuminoso" // Standardfarbe
    
    var body: some View {
        VStack {
            Text("Willkommen zum Onboarding!")
                .font(.largeTitle)
                .padding()
            
            TextField("Benutzername", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Zielsprache", selection: $selectedLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.rawValue).tag(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            // Auswahl für das Farbschema
            Text("Wähle dein Farbschema:")
            Picker("Farbschema", selection: $selectedColorScheme) {
                Text("AzulLuminoso").tag("AzulLuminoso")
                Text("AmberBlaze").tag("AmberBlaze")
                Text("EmeraldTeal").tag("EmeraldTeal")
                Text("VintagePurple").tag("VintagePurple")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // NavigationLink mit value und Ziel
            NavigationLink(value: "OnboardingInfo") {
                Text("Fertig")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onTapGesture {
                Task {
                    await viewModel.updateProfile(username: username, preferredLanguage: selectedLanguage)
                    colorManager.updateColor(to: selectedColorScheme)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        // navigationDestination für das Ziel definieren
        .navigationDestination(for: String.self) { value in
            if value == "OnboardingInfo" {
                OnboardingInfoView(viewModel: viewModel, colorManager: colorManager)
            }
        }
    }
}

#Preview {
    OnboardingUserDataView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
