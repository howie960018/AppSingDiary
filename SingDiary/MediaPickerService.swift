import SwiftUI
import PhotosUI
import AVFoundation

class MediaPickerService: NSObject, ObservableObject {
    @Published var selectedURL: URL?
    @Published var selectedMediaType: String?
    @Published var hasVideo: Bool = false
    @Published var isLoading: Bool = false
    
    // 保存臨時檔案的目錄
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 處理選擇的媒體項目
    func processSelectedItem(_ item: PHPickerResult) {
        isLoading = true
        
        if item.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            item.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                guard let self = self, let originalURL = url else {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                    return
                }
                
                // 創建新檔案路徑
                let fileName = "imported_video_\(Date().timeIntervalSince1970).mov"
                let destinationURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                
                do {
                    // 檢查並刪除現有檔案
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    // 複製檔案到應用目錄
                    try FileManager.default.copyItem(at: originalURL, to: destinationURL)
                    
                    // 驗證新檔案是否包含音頻軌
                    let asset = AVAsset(url: destinationURL)
                    let audioTracks = asset.tracks(withMediaType: .audio)
                    
                    print("影片已保存至: \(destinationURL.path)")
                    print("影片包含 \(audioTracks.count) 條音頻軌")
                    
                    // 更新UI
                    DispatchQueue.main.async {
                        self.selectedURL = destinationURL
                        self.selectedMediaType = "video"
                        self.hasVideo = true
                        self.isLoading = false
                    }
                } catch {
                    print("複製影片檔案錯誤: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        } else {
            // 如果不是影片，取消載入
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
