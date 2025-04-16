import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @ObservedObject var audioRecorder: AudioRecorderService
    @Environment(\.presentationMode) var presentationMode
    let onSave: (URL?) -> Void
    
    var body: some View {
        VStack {
            // 標題
            Text("錄製歌聲")
                .font(.title)
                .bold()
                .padding(.top, 30)
            
            Spacer()
            
            // 錄音波形動畫 (可視化效果)
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                if audioRecorder.isRecording {
                    // 顯示動態波形
                    ForEach(0..<5) { i in
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                            .scaleEffect(CGFloat(0.6 + (Double(i) * 0.1)))
                            .opacity(0.6 - (Double(i) * 0.1))
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: audioRecorder.isRecording)
                    }
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                }
            }
            
            // 計時顯示
            if audioRecorder.isRecording {
                Text(timeString(from: audioRecorder.recordingDuration))
                    .font(.system(size: 50, weight: .semibold, design: .monospaced))
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            // 控制按鈕
            HStack(spacing: 40) {
                // 取消按鈕
                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    }
                    audioRecorder.recordingURL = nil
                    onSave(nil)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("取消")
                            .foregroundColor(.red)
                    }
                }
                
                // 錄音/停止按鈕
                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        if audioRecorder.recordingURL != nil {
                            // 已有錄音，保存並退出
                            onSave(audioRecorder.recordingURL)
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            // 開始新錄音
                            audioRecorder.startRecording()
                        }
                    }
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                                .frame(width: 70, height: 70)
                            
                            if audioRecorder.isRecording {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                                    .cornerRadius(3)
                            } else if audioRecorder.recordingURL != nil {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 25, height: 25)
                            }
                        }
                        
                        Text(audioRecorder.isRecording ? "停止" : (audioRecorder.recordingURL != nil ? "保存" : "錄製"))
                            .foregroundColor(audioRecorder.isRecording ? .red : .blue)
                            .padding(.top, 8)
                    }
                }
                
                // 播放錄音按鈕 (如果已錄製)
                if let _ = audioRecorder.recordingURL, !audioRecorder.isRecording {
                    Button(action: {
                        // 打開播放視圖
                        if let url = audioRecorder.recordingURL {
                            // 創建一個臨時的AudioPlayerService並播放
                            let player = AudioPlayerService()
                            player.startPlayback(url: url)
                        }
                    }) {
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            Text("播放")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 權限提示
            Text("請保持設備靠近您的嘴部，以獲得最佳錄音效果")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .padding()
        .onDisappear {
            if audioRecorder.isRecording {
                audioRecorder.stopRecording()
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


// 音頻播放器視圖
struct AudioPlayerView: View {
    @StateObject private var audioPlayer = AudioPlayerService()
    @Environment(\.presentationMode) var presentationMode
    let url: URL
    
    var body: some View {
        VStack(spacing: 30) {
            Text("錄音播放")
                .font(.title)
                .padding(.top, 30)
            
            Spacer()
            
            // 音頻波形顯示 (或其他視覺效果)
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: audioPlayer.isPlaying ? "waveform.circle" : "waveform.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .opacity(audioPlayer.isPlaying ? 0.8 : 1.0)
                    .scaleEffect(audioPlayer.isPlaying ? 1.1 : 1.0)
                    .animation(audioPlayer.isPlaying ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: audioPlayer.isPlaying)
            }
            
            // 進度條
            VStack {
                Slider(value: Binding(
                    get: { audioPlayer.currentTime },
                    set: { audioPlayer.seek(to: $0) }
                ), in: 0...max(1, audioPlayer.duration))
                .accentColor(.blue)
                
                HStack {
                    Text(formatTime(audioPlayer.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(audioPlayer.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // 控制按鈕
            HStack(spacing: 50) {
                Button(action: {
                    if audioPlayer.isPlaying {
                        audioPlayer.pausePlayback()
                    } else {
                        if audioPlayer.currentTime > 0 {
                            audioPlayer.resumePlayback()
                        } else {
                            audioPlayer.startPlayback(url: url)
                        }
                    }
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Button("關閉") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
        .onAppear {
            audioPlayer.startPlayback(url: url)
        }
        .onDisappear {
            audioPlayer.stopPlayback()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
