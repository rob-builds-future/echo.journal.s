import SwiftUI

struct EchoSymbolView: View {
    @ObservedObject var colorManager: ColorManager // Zugriff auf die Theme-Farbe
    
    var body: some View {
        ZStack {
            // Vier überlagerte Kreise mit Stroke
            ZStack {
                CircleView(size: 215) // Äußerer Kreis
                CircleView(size: 175) // Zweitgrößter Kreis
                CircleView(size: 135) // Drittgrößter Kreis
                CircleView(size: 95)  // Innerster Kreis
            }
        }
    }
}

struct CircleView: View {
    @EnvironmentObject var colorManager: ColorManager
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(colorManager.currentColor.color, lineWidth: 8)
            .frame(width: size, height: size)
    }
}

#Preview {
    EchoSymbolView(colorManager: ColorManager())
        .environmentObject(ColorManager()) // EnvironmentObject für die Vorschau bereitstellen
}
