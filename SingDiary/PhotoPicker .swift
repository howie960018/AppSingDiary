import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var mediaPicker: MediaPickerService
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos  // 只允許選擇影片
        config.selectionLimit = 1  // 一次只能選一個檔案
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            // 處理用戶取消選擇的情況
            if results.isEmpty {
                return
            }
            
            guard let result = results.first else { return }
            
            // 添加錯誤處理
            do {
                try parent.mediaPicker.processSelectedItem(result)
            } catch {
                print("處理選擇的影片時發生錯誤：\(error.localizedDescription)")
                // 可以在這裡添加錯誤提示給用戶
            }
        }
    }
}
