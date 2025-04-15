import Foundation

class TtsRepository {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/audio/speech")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func synthesizeSpeech(text: String, voice: String = "nova") async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": voice,
            "response_format": "mp3"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "TTS", code: 1, userInfo: [NSLocalizedDescriptionKey: "TTS API call failed"])
        }

        return data
    }
}
