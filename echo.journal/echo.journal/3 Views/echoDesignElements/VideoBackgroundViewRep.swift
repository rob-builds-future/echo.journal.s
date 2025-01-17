import SwiftUI
import AVKit

struct VideoBackgroundViewRep: UIViewRepresentable {
    private let player: AVPlayer

    init(videoName: String) {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            fatalError("Video nicht gefunden: \(videoName).mp4")
        }
        self.player = AVPlayer(url: url)
        self.player.isMuted = true
        self.player.play()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds

        view.layer.addSublayer(playerLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // noch kein Update erforderlich, da das Video aktuell persistent ist
    }
}
