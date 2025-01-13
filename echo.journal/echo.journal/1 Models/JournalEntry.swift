import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    let userId: String
    var content: String
    var translatedContent: String? = nil
    var isFavorite: Bool = false
    var language: String = "de"
    let createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var formattedCreatedAt: String {
        createdAt.formatted
    }
    
    var formattedUpdatedAt: String {
        updatedAt.formatted
    }
    
    init(userId: String, content: String) {
        self.userId = userId
        self.content = content
    }
}
