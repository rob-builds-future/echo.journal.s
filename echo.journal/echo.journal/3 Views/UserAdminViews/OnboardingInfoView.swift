import SwiftUI

struct OnboardingInfoView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Echo Guide")
                .font(.largeTitle)
                .padding()
            
            Text("Hier sind einige Informationen über die App und wie du sie nutzen kannst...")
                .padding()
            
            NavigationLink(value: "OnboardingUserData") {
                Text("Weiter")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? .white : .black)
                    .cornerRadius(8)
            }

        }
        .padding()
        .navigationDestination(for: String.self) { value in
            if value == "OnboardingUserData" {
                OnboardingUserDataView(viewModel: viewModel, colorManager: colorManager)
            }
        }
    }
}

#Preview {
    OnboardingInfoView(viewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
