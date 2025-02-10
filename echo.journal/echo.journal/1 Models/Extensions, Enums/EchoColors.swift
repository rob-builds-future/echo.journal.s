import SwiftUI

/// Enum, das alle verfügbaren Echo-Farben enthält
enum EchoColor: String, CaseIterable, Identifiable {
    case lichtblau = "Lichtblau"
    case bernstein = "Bernstein"
    case smaragdgrün = "Smaragdgrün"
    case vintagepurpur = "Vintagepurpur"
    
    var id: String { self.rawValue } // Identifizierbar für Picker
    
    /// Anzeigename für das UI
    var displayName: String {
        switch self {
        case .lichtblau: return "Lichtblau"
        case .bernstein: return "Bernstein"
        case .smaragdgrün: return "Smaragdgrün"
        case .vintagepurpur: return "Vintagepurpur"
        }
    }
    
    /// Die zugehörige SwiftUI-Farbe
    var color: Color {
        Color(self.rawValue)
    }
}
