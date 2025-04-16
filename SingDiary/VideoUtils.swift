import UIKit
import AVFoundation

class VideoUtils {
    // 從影片URL生成縮略圖
    static func generateThumbnail(from videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        // 取片頭第1秒的畫面作為縮略圖
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("生成影片縮略圖失敗: \(error)")
            return nil
        }
    }
    
    // 取得影片時長
    static func getVideoDuration(from videoURL: URL) -> TimeInterval {
        let asset = AVAsset(url: videoURL)
        return CMTimeGetSeconds(asset.duration)
    }
    
    // 複製影片到應用程式文件目錄
    static func copyVideoToDocuments(from sourceURL: URL) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "video_\(Date().timeIntervalSince1970).mp4"
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // 如果來源URL不在應用沙盒內，需要複製
            if !sourceURL.path.contains(documentsDirectory.path) {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
                return destinationURL
            }
            return sourceURL
        } catch {
            print("複製影片失敗: \(error)")
            return nil
        }
    }
    
    // 格式化時間顯示
    static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
