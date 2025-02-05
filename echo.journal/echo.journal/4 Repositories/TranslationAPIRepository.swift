//
//  TranslationRepository.swift
//  echo.journal
//
//  Created by Robin Bettinghausen on 13.01.25.
//

import Foundation

class TranslationAPIRepository {
    private let baseURL = "http://localhost:5001/translate"
    
    func translate(text: String, targetLanguage: String) async throws -> String {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let body: [String: Any] = [
            "q": text,
            "source": "auto", // Automatische Erkennung
            "target": targetLanguage,
            "format": "text"
        ]
        
        do {
            // Log the request details
            print("Base URL: \(baseURL)")
            print("Request Body: \(body)")
          
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            
            // Perform the API call
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log the HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            // Log the response data
            print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            // Parse the response JSON
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let translatedText = json["translatedText"] as? String {
                print("Translated Text: \(translatedText)")
                return translatedText
            } else {
                print("Error: Missing 'translatedText' in response")
                throw NSError(domain: "TranslationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing 'translatedText' in response"])
            }
        } catch let error as URLError {
            // Log the URL error
            print("URLError: \(error.localizedDescription) (Code: \(error.code.rawValue))")
            throw error
        } catch {
            // Log any other errors
            print("Unexpected Error: \(error.localizedDescription)")
            throw error
        }
    }
}
