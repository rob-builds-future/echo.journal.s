import SwiftUI

/// Manager zur Verwaltung des ausgewählten Farbschemas
class ColorManager: ObservableObject {
    @Published var currentColor: EchoColor
    
    private let defaultColor: EchoColor = .azulLuminoso // Standardfarbe
    private let userDefaultsKey = "SelectedThemeColor" // Schlüssel für Persistenz

    init() {
        // Lade die gespeicherte Farbe oder verwende die Standardfarbe
        if let savedColorName = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedColor = EchoColor(rawValue: savedColorName) {
            self.currentColor = savedColor
        } else {
            self.currentColor = defaultColor
        }
    }
    
    /// Aktualisiert das Farbschema und speichert es
    func updateColor(to newColor: EchoColor) {
        self.currentColor = newColor
        UserDefaults.standard.set(newColor.rawValue, forKey: userDefaultsKey)
    }
}
