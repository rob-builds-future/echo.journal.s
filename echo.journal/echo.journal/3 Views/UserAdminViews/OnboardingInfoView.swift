import SwiftUI

struct OnboardingInfoView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager // Zugriff auf den ColorManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Echo Guide")
                .font(.largeTitle)
                .padding()
            
            Text("Hier sind einige Informationen über die App und wie du sie nutzen kannst...")
                .padding()
            
            // Füge hier weitere Informationen hinzu
            
            Button("Fertig") {
                // Onboarding als abgeschlossen markieren
                Task {
                    viewModel.updateOnboardingStatus() // Onboarding als abgeschlossen markieren
                    dismiss() // Schließt die aktuelle Ansicht (falls modal dargestellt)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

#Preview {
    OnboardingInfoView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
