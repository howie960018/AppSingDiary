import SwiftUI
import AVKit

//struct VideoPlayerView: View {
//    var url: URL
//    @Environment(\.presentationMode) var presentationMode
//    
//    init(url: URL) {
//            self.url = url
//            
//            // 嘗試設置音訊會話
//            do {
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//                try AVAudioSession.sharedInstance().setActive(true)
//            } catch {
//                print("設置音訊會話失敗: \(error)")
//            }
//        }
//    
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VideoPlayer(player: AVPlayer(url: url))
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                }
//                Spacer()
//            }
//        }
//    }
//}
import SwiftUI
import AVKit
import UIKit
import AVFoundation

// 視頻播放器視圖
struct VideoPlayerView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: AVPlayer(url: url))
                .onAppear {
                    print("正在播放影片 URL: \(url)")
                    let exists = FileManager.default.fileExists(atPath: url.path)
                    print("影片檔案存在: \(exists)")
                }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
// 相機預覽層視圖
struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var videoRecorder: VideoRecorderService
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        if let previewLayer = videoRecorder.getPreviewLayer() {
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = videoRecorder.getPreviewLayer() {
            previewLayer.frame = UIScreen.main.bounds
        }
    }
}

// 影片預覽和確認視圖
struct VideoPreviewView: View {
    let url: URL
    let onComplete: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VideoThumbnailView(url: url, isPlaying: true)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    // 刪除按鈕
                    Button(action: {
                        onComplete(false)
                    }) {
                        VStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("刪除")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(30)
                    
                    Spacer()
                    
                    // 保存按鈕
                    Button(action: {
                        onComplete(true)
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("保存")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(30)
                }
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

// 視頻錄製視圖
struct VideoRecorderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var videoRecorder: VideoRecorderService
    var onSave: (URL?) -> Void
    
    @State private var showingPreview = false
    
    var body: some View {
        ZStack {
            // 相機預覽層
            CameraPreviewView(videoRecorder: videoRecorder)
                .edgesIgnoringSafeArea(.all)
            
            // 控制按鈕和計時器層
            VStack {
                HStack {
                    Button(action: {
                        videoRecorder.stopSession()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                    
                    Spacer()
                    
                    if videoRecorder.isRecording {
                        Text(timeString(from: videoRecorder.recordingDuration))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
                
                // 錄製控制按鈕
                HStack(spacing: 30) {
                    if videoRecorder.isRecording {
                        // 停止按鈕
                        Button(action: {
                            videoRecorder.stopRecording()
                            showingPreview = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 70, height: 70)
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                                    .cornerRadius(3)
                            }
                        }
                    } else {
                        // 開始錄製按鈕
                        Button(action: {
                            videoRecorder.startRecording()
                        }) {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                )
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            videoRecorder.setupCamera()
        }
        .onDisappear {
            videoRecorder.stopSession()
        }
        .overlay(
            Group {
                if showingPreview, let url = videoRecorder.recordingURL {
                    VideoPreviewView(url: url) { saved in
                        if saved {
                            onSave(url)
                        } else {
                            onSave(nil)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .transition(.opacity)
                    .animation(.default, value: showingPreview)
                }
            }
        )
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
