import SwiftUI
import AVFoundation

// 視頻縮略圖視圖
struct VideoThumbnailView: UIViewRepresentable {
    let url: URL
    var isPlaying: Bool = true
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        // 設置自適應
        context.coordinator.playerLayer = playerLayer
        
        // 根據isPlaying決定是否自動播放
        if isPlaying {
            player.play()
            
            // 循環播放
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main) { _ in
                    player.seek(to: CMTime.zero)
                    player.play()
                }
        } else {
            // 如果不是播放狀態，先播放然後暫停於第一幀
            player.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                player.pause()
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新佈局
        context.coordinator.playerLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// 預覽
struct VideoThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        // 這裡使用一個假的URL，在實際環境中不會工作
        VideoThumbnailView(url: URL(string: "file://dummy.mp4")!)
            .frame(width: 200, height: 150)
            .previewLayout(.sizeThatFits)
    }
}
