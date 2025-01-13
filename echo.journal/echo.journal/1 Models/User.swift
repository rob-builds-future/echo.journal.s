import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var preferredLanguage: String = "de"
    let createdAt: Date = Date()
    
    var formattedCreatedAt: String {
        createdAt.formatted
    }
    
    init(id: String, email: String, username: String) {
        self.id = id
        self.email = email
        self.username = username
    }
}
