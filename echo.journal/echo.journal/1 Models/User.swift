import Foundation

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var email: String
    var username: String
    var preferredLanguage: String = "de"
    let createdAt: Date = Date()
    
    var formattedCreatedAt: String {
        createdAt.formatted
    }
    
    init(email: String, username: String) {
        self.email = email
        self.username = username
    }
}
