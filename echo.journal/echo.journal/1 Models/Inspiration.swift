import Foundation

struct Inspiration: Identifiable {
    let id: String
    let text: String
    let author: String?  // Optional, falls du auch den Autor speichern möchtest
}
