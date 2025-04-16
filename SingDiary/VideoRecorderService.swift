import Foundation
import AVFoundation
import UIKit

class VideoRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var recordingDuration: TimeInterval = 0
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var timer: Timer?
    
    // 獲取視頻預覽層
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    // 初始化攝像頭
    func setupCamera() {
        // 釋放舊的會話資源
        if captureSession != nil {
            stopSession()
            captureSession = nil
            previewLayer = nil
        }
        
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // 設置為中等品質以提高兼容性
        if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
        }
        
        // 找到前置攝像頭
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("找不到攝影機")
            return
        }
        
        // 找到麥克風
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("找不到麥克風")
            return
        }
        
        do {
            // 添加視頻輸入
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // 添加音頻輸入
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
            
            // 添加視頻輸出
            videoOutput = AVCaptureMovieFileOutput()
            if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                
                // 確保影片方向正確
                if let connection = videoOutput.connection(with: .video) {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                    
                    // 如果是前置鏡頭，可能需要翻轉
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = true
                    }
                }
            }
            
            captureSession.commitConfiguration()
            
            // 設置預覽層 - 確保在設置後建立
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            
            // 在主線程啟動相機會話
            print("準備啟動相機會話")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
                print("相機會話已啟動")
            }
        } catch {
            print("相機設定錯誤: \(error.localizedDescription)")
        }
    }
    
    // 獲取文檔目錄
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 開始錄製
    func startRecording() {
        guard let captureSession = captureSession, let videoOutput = videoOutput else {
            print("無法開始錄製：相機未初始化")
            return
        }
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
        
        // 生成唯一文件名
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // 確保先前的錄製已停止
        if isRecording {
            stopRecording()
        }
        
        // 確保文件路徑可寫入
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // 直接設置recordingURL，不要等到錄製完成
        self.recordingURL = fileURL
        
        // 延遲一點時間確保相機已經準備好
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.videoOutput?.startRecording(to: fileURL, recordingDelegate: self)
            self.isRecording = true
            self.recordingDuration = 0
            
            // 開始計時
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.recordingDuration += 0.1
            }
        }
    }
    
    // 停止錄製
    func stopRecording() {
        if isRecording {
            videoOutput?.stopRecording()
            timer?.invalidate()
            timer = nil
        }
    }
    
    // 停止捕捉會話
    func stopSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
}

extension VideoRecorderService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // 檢查文件是否成功建立
        let fileExists = FileManager.default.fileExists(atPath: outputFileURL.path)
        print("錄製完成，文件存在: \(fileExists)，路徑: \(outputFileURL.path)")
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.timer?.invalidate()
            self.timer = nil
            
            if let error = error {
                print("影片錄製錯誤: \(error.localizedDescription)")
                return
            }
            
            if !fileExists {
                print("找不到錄製的視頻文件")
                return
            }
            
            // 我們已經在startRecording中設置了recordingURL
            // 因此這裡不需要再設置，除非需要移動文件
        }
    }
}
