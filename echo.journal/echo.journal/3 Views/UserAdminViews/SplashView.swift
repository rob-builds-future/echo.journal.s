import SwiftUI

struct SplashView: View {
    @ObservedObject var colorManager: ColorManager
    
    var body: some View {
        EchoSymbolBounceView(colorManager: colorManager)
    }
}

#Preview {
    SplashView(colorManager: ColorManager())
}
