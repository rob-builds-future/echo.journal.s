import SwiftUI
import FirebaseCore

@main
struct echo_journalApp: App {
    @StateObject private var colorManager = ColorManager() // ColorManager erstellen
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(colorManager) // ColorManager global bereitstellen
        }
    }
}
