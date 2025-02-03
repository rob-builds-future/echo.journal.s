import AVFoundation

// Enum zur Darstellung des aktuellen Speech-Status
enum SpeechState {
    case idle, playing, paused
}

// Delegate-Klasse, um das Ende der Wiedergabe mitzuteilen
class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    var onFinish: (() -> Void)?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onFinish?()
        }
    }
}
