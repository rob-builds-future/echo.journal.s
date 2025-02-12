import SwiftUI

struct OnboardingInfoView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showPopover = false
    
    // Standardfarbe: schwarz im Light Mode, weiß im Dark Mode.
    var defaultTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            // Erstes Drittel: Begrüßungstext, leading ausgerichtet
            VStack(alignment: .leading) {
                (
                    Text("Lerne ")
                        .foregroundColor(defaultTextColor)
                    + Text("echo")
                        .foregroundColor(colorManager.currentColor.color)
                    + Text(" kennen – dein Begleiter in dieser App.")
                        .foregroundColor(defaultTextColor)
                )
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()
            }
            
            
            // Zweites Drittel: Bild-Button mit Popover
            Button(action: {
                showPopover = true
            }) {
                ZStack {
                    EchoSymbolBounceView(colorManager: colorManager)
                        .scaleEffect(0.7)
                        .frame(height: 180)
                    if showPopover == false {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
                ZStack {
                    Text("Hey, ich bin echo!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Color.clear
                        .scaleEffect(2)
                }
                .padding()
                .presentationCompactAdaptation(.popover)
                .background(colorManager.currentColor.color)
            }
            .padding()
            
            Spacer()
            
            // Drittes Drittel: Motivations-Text, leading ausgerichtet
            VStack(alignment: .leading) {
                Text("Betrachte es als die Stimme deines Zukunfts-Ich, das mit Dir deine Sprachziele erreicht.")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(defaultTextColor)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            
            Spacer()
            
            // NavigationLink am unteren Rand
            NavigationLink(value: "OnboardingUserData") {
                Text("Weiter")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? .white : .black)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .padding(.horizontal)
        .navigationDestination(for: String.self) { value in
            if value == "OnboardingUserData" {
                OnboardingUserDataView(viewModel: viewModel, colorManager: colorManager)
            }
        }
    }
}

