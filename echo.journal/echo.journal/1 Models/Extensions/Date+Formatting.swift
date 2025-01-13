import Foundation

extension Date {
    // Lesbares Datum für UI
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        
        return formatter.string(from: self)
    }
    
}
