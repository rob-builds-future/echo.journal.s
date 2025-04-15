import AVFoundation
import SwiftUI

@MainActor
class SpeechViewModel: ObservableObject {
    @Published var speechState: SpeechState = .idle
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechDelegate = SpeechDelegate()
    
    init() {
        speechSynthesizer.delegate = speechDelegate
        speechDelegate.onFinish = { [weak self] in
            self?.speechState = .idle
        }
    }
    
    func speak(text: String, language: String = "pt-BR", voiceName: String? = nil) {
        guard !text.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceName.flatMap { name in
            AVSpeechSynthesisVoice.speechVoices().first { $0.name == name && $0.language == language }
        } ?? AVSpeechSynthesisVoice(language: language)
        
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
        speechState = .playing
    }
    
    func toggleSpeech(text: String) {
        if speechSynthesizer.isSpeaking {
            if speechState == .playing {
                speechSynthesizer.pauseSpeaking(at: .word)
                speechState = .paused
            } else if speechState == .paused {
                speechSynthesizer.continueSpeaking()
                speechState = .playing
            }
        } else {
            speak(text: text)
        }
    }
    
    func iconForSpeechState() -> String {
        switch speechState {
        case .idle: return "speaker.wave.2.fill"
        case .playing: return "pause.fill"
        case .paused: return "play.fill"
        }
    }
}
