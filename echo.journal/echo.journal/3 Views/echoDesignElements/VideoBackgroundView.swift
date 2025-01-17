import SwiftUI
import AVKit

struct VideoBackgroundView: View {
    private let player: AVPlayer

    init(videoName: String) {
        // Lade das Video
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            fatalError("Video nicht gefunden: \(videoName).mp4")
        }

        // Initialisiere den AVPlayer
        self.player = AVPlayer(url: url)
        self.player.isMuted = true // Stummschalten

        // Stoppe die Wiedergabe am Ende des Videos
        self.player.actionAtItemEnd = .pause
    }

    var body: some View {
        GeometryReader { geometry in
            VideoPlayer(player: player)
                .aspectRatio(contentMode: .fill) // Skaliere das Video, um den gesamten Bildschirm auszufüllen
                .frame(width: geometry.size.width, height: geometry.size.height) // Passe die Größe an den gesamten Bildschirm an
                .clipped() // Schneide den Überhang ab, wenn das Seitenverhältnis nicht übereinstimmt
                .onAppear {
                    player.play() // Video automatisch starten
                }
                .onDisappear {
                    player.pause() // Video anhalten, wenn die View verschwindet
                }
        }
        .edgesIgnoringSafeArea(.all) // Vollbild inklusive Safe Areas
    }
}
