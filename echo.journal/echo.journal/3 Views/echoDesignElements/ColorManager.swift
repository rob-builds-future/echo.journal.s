import SwiftUI

class ColorManager: ObservableObject {
    @Published var currentColor: Color
    
    private let defaultColorName = "AzulLuminoso" // Standardfarbe
    private let userDefaultsKey = "SelectedThemeColor" // Schlüssel für Persistenz

    init() {
        // Lade die gespeicherte Farbe oder verwende die Standardfarbe
        if let savedColorName = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.currentColor = Color(savedColorName)
        } else {
            self.currentColor = Color(defaultColorName)
        }
    }
    
    func updateColor(to newColorName: String) {
        // Aktualisiere die Farbe und speichere sie
        self.currentColor = Color(newColorName)
        UserDefaults.standard.set(newColorName, forKey: userDefaultsKey)
    }
}
