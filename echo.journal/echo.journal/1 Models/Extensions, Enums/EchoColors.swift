import SwiftUI

/// Enum, das alle verfügbaren Echo-Farben enthält
enum EchoColor: String, CaseIterable, Identifiable {
    case azulLuminoso = "AzulLuminoso"
    case amberBlaze = "AmberBlaze"
    case emeraldTeal = "EmeraldTeal"
    case vintagePurple = "VintagePurple"
    
    var id: String { self.rawValue } // Identifizierbar für Picker
    
    /// Anzeigename für das UI
    var displayName: String {
        switch self {
        case .azulLuminoso: return "Azul Luminoso"
        case .amberBlaze: return "Amber Blaze"
        case .emeraldTeal: return "Emerald Teal"
        case .vintagePurple: return "Vintage Purple"
        }
    }
    
    /// Die zugehörige SwiftUI-Farbe
    var color: Color {
        Color(self.rawValue)
    }
}
