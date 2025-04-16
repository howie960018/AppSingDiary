//import SwiftUI
//import UIKit
//import PhotosUI
//import AVKit
//
//struct MediaPicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Binding var selectedVideoURL: URL?
//    @Binding var isPresented: Bool
//    var sourceType: UIImagePickerController.SourceType
//    var mediaTypes: [String] = ["public.image", "public.movie"]
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.mediaTypes = mediaTypes
//        picker.delegate = context.coordinator
//        picker.videoQuality = .typeHigh
//        picker.allowsEditing = false
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: MediaPicker
//        
//        init(_ parent: MediaPicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            // 檢查媒體類型
//            let mediaType = info[.mediaType] as! String
//            
//            if mediaType == "public.image" {
//                // 處理照片
//                if let image = info[.originalImage] as? UIImage {
//                    parent.selectedImage = image
//                    parent.selectedVideoURL = nil
//                    
//                    if picker.sourceType == .camera {
//                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    }
//                }
//            } else if mediaType == "public.movie" {
//                // 處理影片
//                if let videoURL = info[.mediaURL] as? URL {
//                    parent.selectedVideoURL = videoURL
//                    parent.selectedImage = nil
//                    
//                    // 如果是相機拍攝的影片，保存到相簿
//                    if picker.sourceType == .camera {
//                        PHPhotoLibrary.shared().performChanges {
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
//                        } completionHandler: { success, error in
//                            if !success {
//                                print("保存影片到相簿失敗: \(String(describing: error))")
//                            }
//                        }
//                    }
//                }
//            }
//            
//            parent.isPresented = false
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.isPresented = false
//        }
//    }
//}
import SwiftUI
import UIKit
import PhotosUI
import AVKit

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    var mediaTypes: [String] = ["public.image", "public.movie"]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        picker.videoQuality = .typeHigh
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 檢查媒體類型
            let mediaType = info[.mediaType] as! String
            
            if mediaType == "public.image" {
                // 處理照片
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                    parent.selectedVideoURL = nil
                    
                    if picker.sourceType == .camera {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
            } else if mediaType == "public.movie" {
                // 處理影片
                if let videoURL = info[.mediaURL] as? URL {
                    parent.selectedVideoURL = videoURL
                    parent.selectedImage = nil
                    
                    // 如果是相機拍攝的影片，保存到相簿
                    if picker.sourceType == .camera {
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                        } completionHandler: { success, error in
                            if !success {
                                print("保存影片到相簿失敗: \(String(describing: error))")
                            }
                        }
                    }
                }
            }
            
            // 主動關閉 picker 視圖
            parent.isPresented = false
            picker.dismiss(animated: true)
        }
        
    
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 主動關閉 picker 視圖
            parent.isPresented = false
            picker.dismiss(animated: true)
        }
    }
}
