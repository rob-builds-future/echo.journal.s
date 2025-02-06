import Foundation

class TranslationAPIRepository {
    // Basis-URL des lokalen Übersetzungsservers
    private let baseURL = "http://localhost:5001/translate"
    
    /// Führt eine asynchrone Übersetzung durch.
    /// - Parameters:
    ///   - text: Der zu übersetzende Text.
    ///   - targetLanguage: Die Zielsprache (z. B. "de" für Deutsch).
    /// - Returns: Der übersetzte Text als `String`.
    /// - Throws: Fehler bei Netzwerk- oder JSON-Verarbeitungsproblemen.
    func translate(text: String, targetLanguage: String) async throws -> String {
        // Erzeuge die URL, werfe Fehler, falls ungültig
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        // Erstelle die HTTP-Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10  // Timeout nach 10 Sekunden
        
        // Erstelle den JSON-Request-Body
        let body: [String: Any] = [
            "q": text,             // Der zu übersetzende Text
            "source": "auto",      // Automatische Spracherkennung
            "target": targetLanguage, // Zielsprachen-Code
            "format": "text"       // Format als einfacher Text
        ]
        
        do {
            // Debugging: Logge die Anfrage
            print("Base URL: \(baseURL)")
            print("Request Body: \(body)")
            
            // Konvertiere den Request-Body in JSON-Daten
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Führe den API-Call aus und erhalte die Antwort
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debugging: Logge die HTTP-Response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            // Debugging: Logge die Antwortdaten als String
            print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            // Versuche, die Antwort als JSON zu parsen
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let translatedText = json["translatedText"] as? String {
                print("Translated Text: \(translatedText)") // Debugging-Log
                return translatedText
            } else {
                // Falls die Antwort nicht das erwartete Format hat
                print("Error: Missing 'translatedText' in response")
                throw NSError(domain: "TranslationError", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Missing 'translatedText' in response"
                ])
            }
        } catch let error as URLError {
            // Fehlerhandling bei Netzwerkfehlern
            print("URLError: \(error.localizedDescription) (Code: \(error.code.rawValue))")
            throw error
        } catch {
            // Fehlerhandling bei anderen Fehlern (z. B. JSON-Parsing)
            print("Unexpected Error: \(error.localizedDescription)")
            throw error
        }
    }
}
