import SwiftUI

// Eigene Shape für spezifische Ecken
struct CustomCornerShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                topLeft > 0 ? .topLeft : [],
                topRight > 0 ? .topRight : [],
                bottomLeft > 0 ? .bottomLeft : [],
                bottomRight > 0 ? .bottomRight : []
            ].reduce([]) { $0.union($1) },
            cornerRadii: CGSize(width: 12, height: 12)
        )
        return Path(path.cgPath)
    }
}
