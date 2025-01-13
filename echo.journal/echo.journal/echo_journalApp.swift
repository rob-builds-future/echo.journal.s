import SwiftUI
import FirebaseCore

@main
struct echo_journalApp: App {
    
    init() {
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
