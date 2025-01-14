
enum Language: String, CaseIterable, Identifiable, Codable {
    case en = "Englisch"
    case de = "Deutsch"
    case pt = "Portugiesisch"
    
    var id: String { self.rawValue }
}
