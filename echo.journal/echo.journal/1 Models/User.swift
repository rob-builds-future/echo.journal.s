import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var preferredLanguage: Language
    var createdAt: Date

    
    init(id: String, email: String, username: String, preferredLanguage: Language, createdAt: Date) {
        self.id = id
        self.email = email
        self.username = username
        self.preferredLanguage = preferredLanguage
        self.createdAt = createdAt
    }
}
