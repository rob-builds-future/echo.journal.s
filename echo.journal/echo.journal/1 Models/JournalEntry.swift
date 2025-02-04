import Foundation

struct JournalEntry: Identifiable, Codable, Hashable {
    var id: String = ""
    let userId: String
    var content: String
    var duration: Double
    var createdAt: Date
    var updatedAt: Date? = nil
    var isFavorite: Bool = false
    
    init(userId: String, content: String, duration: Double, createdAt: Date) {
        self.userId = userId
        self.content = content
        self.duration = duration
        self.createdAt = createdAt
    }
}
