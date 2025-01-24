import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var preferredLanguage: Language
    var createdAt: Date = Date()

    
    init(id: String, email: String, username: String, preferredLanguage: Language) {
        self.id = id
        self.email = email
        self.username = username
        self.preferredLanguage = preferredLanguage
    }
}
