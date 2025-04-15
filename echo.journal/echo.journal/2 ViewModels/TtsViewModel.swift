import Foundation
import AVFoundation

@MainActor
class TtsViewModel: ObservableObject {
    private let repository: TtsRepository
    internal var audioPlayer: AVAudioPlayer?

    init() {
        // Lade den API Key aus Info.plist
        if let openAiApiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String, !openAiApiKey.isEmpty {
            print("API Key geladen: \(openAiApiKey)")  // API Key wird geladen
            self.repository = TtsRepository(apiKey: openAiApiKey)
        } else {
            print("Kein API Key gefunden!")  // Fehlermeldung, falls kein API Key gefunden wird
            self.repository = TtsRepository(apiKey: "") // Leere API für den Notfall
        }
    }

    func play(text: String, voice: String = "nova") async {
        do {
            let audioData = try await repository.synthesizeSpeech(text: text, voice: voice)
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("TTS Error: \(error.localizedDescription)")
        }
    }
}
