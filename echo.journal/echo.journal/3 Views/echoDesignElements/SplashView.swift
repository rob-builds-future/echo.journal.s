import SwiftUI

struct SplashView: View {
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            EchoSymbolBounceView(colorManager: colorManager)
            Text("e.")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

#Preview {
    SplashView(colorManager: ColorManager())
}
