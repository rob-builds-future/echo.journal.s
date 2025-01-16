import SwiftUI

struct EchoSymbolBounce: View {
    @EnvironmentObject var colorManager: ColorManager // Zugriff auf die Theme-Farbe
    @Environment(\.colorScheme) var colorScheme // Zugriff auf das aktuelle Farbschema (Light/Dark Mode)
    
    var body: some View {
        ZStack {
            // Dynamischer Hintergrund basierend auf dem Farbschema
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Animierte Kreise
            ZStack {
                AnimatedCircleView(size: 215, delay: 0.6) // Äußerer Kreis
                AnimatedCircleView(size: 175, delay: 0.4) // Zweitgrößter Kreis
                AnimatedCircleView(size: 135, delay: 0.2) // Drittgrößter Kreis
                AnimatedCircleView(size: 95, delay: 0.0)  // Innerster Kreis
            }
        }
    }
}

struct AnimatedCircleView: View {
    @EnvironmentObject var colorManager: ColorManager // Zugriff auf die Theme-Farbe
    let size: CGFloat
    let delay: Double
    
    @State private var scale: CGFloat = 1.0 // Animationszustand

    var body: some View {
        Circle()
            .stroke(colorManager.currentColor, lineWidth: 8) // Stroke mit Theme-Farbe und fester Breite
            .frame(width: size, height: size) // Größe des Kreises
            .scaleEffect(scale) // Skalierung des Kreises animieren
            .onAppear {
                withAnimation(
                    Animation.interpolatingSpring(stiffness: 100, damping: 2)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    scale = 1.2 // Kreis springt leicht nach außen
                }
            }
    }
}

#Preview {
    EchoSymbolBounce()
        .environmentObject(ColorManager()) // ColorManager explizit bereitstellen
}
