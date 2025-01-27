
enum Language: String, CaseIterable, Identifiable, Codable {
    case en = "Englisch"
    case de = "Deutsch"
    case pt = "Portugiesisch"
    case es = "Spanisch"
    case fr = "Französisch"
    
    var id: String { self.rawValue }
    
    var code: String {
        switch self {
        case .en: return "en"
        case .pt: return "pt"
        case .de: return "de"
        case .es: return "es"
        case .fr: return "fr"
        }
    }
}
