import SwiftUI

struct EchoSymbol: View {
    @EnvironmentObject var colorManager: ColorManager // Zugriff auf die Theme-Farbe
    @Environment(\.colorScheme) var colorScheme // Zugriff auf das aktuelle Farbschema (Light/Dark Mode)
    
    var body: some View {
        ZStack {
            // Dynamischer Hintergrund basierend auf dem Farbschema
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
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
    @EnvironmentObject var colorManager: ColorManager // Zugriff auf die Theme-Farbe
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(colorManager.currentColor, lineWidth: 8) // Stroke mit Theme-Farbe und fester Breite
            .frame(width: size, height: size) // Größe des Kreises
    }
}

#Preview {
    EchoSymbol()
        .environmentObject(ColorManager()) // ColorManager explizit bereitstellen
}
