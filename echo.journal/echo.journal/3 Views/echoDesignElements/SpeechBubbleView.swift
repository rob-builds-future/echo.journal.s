import SwiftUI

struct SpeechBubbleView: View {
    var text: String
    var backgroundColor: Color
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Hauptkörper der Sprechblase
            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor) // Dynamische Hintergrundfarbe
                    .shadow(radius: 5)
            )
            .padding(.trailing, 20) // Platz für das Triangle

            // Spitze der Sprechblase
            RoundedTriangle()
                .fill(backgroundColor)
                .frame(width: 30, height: 20) // Größe des Triangles
        }
    }
}

// Abgerundetes Triangle für die Spitze der Sprechblase
struct RoundedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // Linker oberer Punkt
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Spitze in der Mitte rechts
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Unterer linker Punkt
        //path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: rect.minX - 5, y: rect.midY)) // Abrundung
        path.closeSubpath()
        return path
    }
}
