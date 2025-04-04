import Foundation

class TranslationAPIRepository {
    // Basis-URL des Übersetzungsservers
    private let baseURL = "https://libre4echo.de/translate"
    
    // Eigene URLSession mit erhöhter Timeout-Konfiguration
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        // Erhöhe den Timeout für einzelne Requests (z. B. auf 20 Sekunden)
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    // Translate Funktion
    func translate(text: String, targetLanguage: String, sourceLanguage: String) async throws -> String {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "q": text,
            "source": sourceLanguage,
            "target": targetLanguage,
            "format": "text"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Daten vom Server abrufen
        let (data, _) = try await session.data(for: request)
        
        // Debug-Print: Den rohen Response-Body als String ausgeben
        let rawResponse = String(data: data, encoding: .utf8)
        print("Response: \(rawResponse ?? "kein Inhalt")")
        
        // JSON parsen
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let translatedText = json["translatedText"] as? String {
            return translatedText
        } else {
            throw NSError(domain: "TranslationError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Missing 'translatedText' in response"
            ])
        }
    }

    // Führt eine Übersetzung für Top‑Words durch und gibt ein strukturiertes Ergebnis zurück.
        func translateForTopWord(text: String, targetLanguage: String, sourceLanguage: String, alternatives: Int) async throws -> TopWordTranslation {
            guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let body: [String: Any] = [
                "q": text,
                "source": sourceLanguage,      // Hier z. B. "de"
                "target": targetLanguage,        // z. B. der Code der userPreferredLanguage
                "format": "text",
                "alternatives": alternatives   // z. B. 3
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // JSON parsen: Wir erwarten "translatedText" und "alternatives"
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let mainText = json["translatedText"] as? String {
                let alternativesArray = json["alternatives"] as? [String] ?? []
                return TopWordTranslation(main: mainText, alternatives: alternativesArray)
            } else {
                throw NSError(domain: "TranslationError", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Missing expected keys in response"
                ])
            }
        }
}
