
enum Language: String, CaseIterable, Identifiable, Codable {
    case en = "Englisch"
    case de = "Deutsch"
    case pt = "Portugiesisch"
    case es = "Spanisch"
    case fr = "Französisch"
    
    var id: String { self.rawValue }
}
