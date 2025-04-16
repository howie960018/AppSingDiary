//import SwiftUI
//import PhotosUI
//import AVFoundation
//import CoreData
//
//// 定義媒體項目結構
//struct MediaItem: Identifiable, Equatable {
//    var id = UUID()
//    var type: MediaType
//    var imageData: Data?
//    var videoURL: URL?
//    var thumbnailImage: UIImage?
//    var localURL: URL?
//    
//    // 用於支援Equatable協議
//    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    // 生成縮略圖
//    mutating func generateThumbnail() {
//        if type == .image, let imageData = imageData {
//            thumbnailImage = UIImage(data: imageData)
//        } else if type == .video, let videoURL = videoURL {
//            thumbnailImage = VideoUtils.generateThumbnail(from: videoURL)
//        }
//    }
//}
//
//// 媒體類型枚舉
//enum MediaType: String, Codable {
//    case image
//    case video
//    case audio
//}
//
//// 多媒體管理器
//class MultiMediaManager: ObservableObject {
//    @Published var mediaItems: [MediaItem] = []
//    @Published var isLoading: Bool = false
//    
//    // 清除所有媒體項目
//    func clearAll() {
//        mediaItems.removeAll()
//    }
//    
//    // 添加圖片
//    func addImage(_ image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//        
//        var newItem = MediaItem(type: .image, imageData: imageData)
//        newItem.generateThumbnail()
//        
//        DispatchQueue.main.async {
//            self.mediaItems.append(newItem)
//        }
//    }
//    
//    // 添加影片
//    func addVideo(from url: URL) {
//        var newItem = MediaItem(type: .video, videoURL: url)
//        newItem.generateThumbnail()
//        
//        DispatchQueue.main.async {
//            self.mediaItems.append(newItem)
//        }
//    }
//    
//    // 移除指定媒體項目
//    func removeItem(at index: Int) {
//        guard index < mediaItems.count else { return }
//        mediaItems.remove(at: index)
//    }
//    
//    // 移除指定媒體項目（通過ID）
//    func removeItem(withID id: UUID) {
//        if let index = mediaItems.firstIndex(where: { $0.id == id }) {
//            mediaItems.remove(at: index)
//        }
//    }
//    
//    // 保存媒體文件到本地目錄，返回保存後的URLs
//    func saveMediaItems() -> [URL] {
//        var savedURLs: [URL] = []
//        
//        for (index, item) in mediaItems.enumerated() {
//            if item.type == .image, let imageData = item.imageData {
//                let fileName = "media_image_\(Date().timeIntervalSince1970)_\(index).jpg"
//                let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//                
//                do {
//                    try imageData.write(to: fileURL)
//                    savedURLs.append(fileURL)
//                } catch {
//                    print("保存圖片失敗: \(error)")
//                }
//            } else if item.type == .video, let videoURL = item.videoURL {
//                if let savedURL = VideoUtils.copyVideoToDocuments(from: videoURL) {
//                    savedURLs.append(savedURL)
//                }
//            }
//        }
//        
//        return savedURLs
//    }
//    
//    // 從CoreData實體中加載媒體
//    func loadFromURLStrings(_ urlStrings: [String]) {
//        mediaItems.removeAll()
//        
//        for urlString in urlStrings {
//            guard let url = URL(string: urlString) else { continue }
//            
//            let pathExtension = url.pathExtension.lowercased()
//            if ["jpg", "jpeg", "png"].contains(pathExtension) {
//                // 處理圖片
//                do {
//                    let imageData = try Data(contentsOf: url)
//                    var newItem = MediaItem(type: .image, imageData: imageData, localURL: url)
//                    newItem.generateThumbnail()
//                    mediaItems.append(newItem)
//                } catch {
//                    print("加載圖片數據失敗: \(error)")
//                }
//            } else if ["mp4", "mov", "m4v"].contains(pathExtension) {
//                // 處理影片
//                var newItem = MediaItem(type: .video, videoURL: url, localURL: url)
//                newItem.generateThumbnail()
//                mediaItems.append(newItem)
//            }
//        }
//    }
//    
//    private func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//}
//
//// CoreData擴展 - 為實體添加媒體URLs存儲功能
//extension NSManagedObject {
//    // 設置媒體URLs
//    func setMediaURLs(_ urls: [URL]) {
//        let urlStrings = urls.map { $0.absoluteString }
//        if self.responds(to: NSSelectorFromString("mediaURLs")) {
//            self.setValue(urlStrings, forKey: "mediaURLs")
//        }
//    }
//    
//    // 獲取媒體URLs
//    func getMediaURLs() -> [String] {
//        if let urlStrings = self.value(forKey: "mediaURLs") as? [String] {
//            return urlStrings
//        }
//        return []
//    }
//}
//
//// 媒體網格視圖 - 用於顯示和選擇多個媒體項目
//struct MediaGridView: View {
//    @ObservedObject var mediaManager: MultiMediaManager
//    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
//    @State private var showingMediaPicker = false
//    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
//    @State private var showingMediaSourceOptions = false
//    @State private var showingVideoPlayer = false
//    @State private var selectedVideoURL: URL?
//    @State private var selectedImageForFullScreen: UIImage?
//    @State private var showingFullScreenImage = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("媒體檔案").font(.headline)
//            
//            // 媒體網格
//            if !mediaManager.mediaItems.isEmpty {
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 10) {
//                        ForEach(mediaManager.mediaItems) { item in
//                            MediaItemView(item: item) {
//                                // 點擊動作
//                                if item.type == .video, let url = item.videoURL {
//                                    selectedVideoURL = url
//                                    showingVideoPlayer = true
//                                } else if item.type == .image, let image = item.thumbnailImage {
//                                    selectedImageForFullScreen = image
//                                    showingFullScreenImage = true
//                                }
//                            } onDelete: {
//                                // 刪除動作
//                                mediaManager.removeItem(withID: item.id)
//                            }
//                        }
//                        
//                        // 添加媒體按鈕
//                        Button(action: {
//                            showingMediaSourceOptions = true
//                        }) {
//                            VStack {
//                                Image(systemName: "plus.circle")
//                                    .font(.system(size: 30))
//                                    .foregroundColor(.blue)
//                                Text("添加")
//                                    .font(.caption)
//                                    .foregroundColor(.blue)
//                            }
//                            .frame(height: 100)
//                            .frame(maxWidth: .infinity)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                        }
//                    }
//                    .padding(.vertical, 5)
//                }
//                .frame(height: 250)
//            } else {
//                // 無媒體時的添加按鈕
//                Button(action: {
//                    showingMediaSourceOptions = true
//                }) {
//                    HStack {
//                        Image(systemName: "photo.on.rectangle.angled")
//                            .foregroundColor(.blue)
//                        Text("添加照片或影片")
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                }
//            }
//        }
//        .actionSheet(isPresented: $showingMediaSourceOptions) {
//            ActionSheet(
//                title: Text("選擇媒體來源"),
//                buttons: [
//                    .default(Text("拍照")) {
//                        mediaPickerSourceType = .camera
//                        showingMediaPicker = true
//                    },
//                    .default(Text("錄製影片")) {
//                        mediaPickerSourceType = .camera
//                        showingMediaPicker = true
//                    },
//                    .default(Text("從相簿選擇")) {
//                        mediaPickerSourceType = .photoLibrary
//                        showingMediaPicker = true
//                    },
//                    .cancel()
//                ]
//            )
//        }
//        .sheet(isPresented: $showingMediaPicker) {
//            MediaPickerHelper(mediaManager: mediaManager, isPresented: $showingMediaPicker, sourceType: mediaPickerSourceType)
//        }
//        .fullScreenCover(isPresented: $showingVideoPlayer) {
//            if let url = selectedVideoURL {
//                VideoPlayerView(url: url)
//            }
//        }
//        .fullScreenCover(isPresented: $showingFullScreenImage) {
//            if let image = selectedImageForFullScreen {
//                FullScreenImageView(image: image, isPresented: $showingFullScreenImage)
//            }
//        }
//    }
//}
//
//struct FullScreenImageView: View {
//    let image: UIImage
//    @Binding var isPresented: Bool
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFit()
//                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        isPresented = false
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
//
//// 單個媒體項目視圖
//struct MediaItemView: View {
//    let item: MediaItem
//    let onTap: () -> Void
//    let onDelete: () -> Void
//    
//    @State private var showDeleteConfirm = false
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            // 媒體內容
//            if let thumbnail = item.thumbnailImage {
//                Image(uiImage: thumbnail)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(minWidth: 0, maxWidth: .infinity)
//                    .frame(height: 100)
//                    .clipped()
//                    .cornerRadius(8)
//                    .overlay(
//                        // 視頻播放圖標
//                        item.type == .video ?
//                            Image(systemName: "play.circle.fill")
//                                .font(.system(size: 30))
//                                .foregroundColor(.white)
//                                .shadow(radius: 2)
//                            : nil
//                    )
//                    .onTapGesture {
//                        onTap()
//                    }
//            } else {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(height: 100)
//                    .cornerRadius(8)
//                    .overlay(
//                        Text(item.type == .video ? "影片" : "圖片")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    )
//                    .onTapGesture {
//                        onTap()
//                    }
//            }
//            
//            // 刪除按鈕
//            Button(action: {
//                showDeleteConfirm = true
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.white)
//                    .background(Circle().fill(Color.black.opacity(0.6)))
//                    .padding(5)
//            }
//            .alert(isPresented: $showDeleteConfirm) {
//                Alert(
//                    title: Text("確認刪除"),
//                    message: Text("你確定要刪除此媒體嗎？"),
//                    primaryButton: .destructive(Text("刪除")) {
//                        onDelete()
//                    },
//                    secondaryButton: .cancel(Text("取消"))
//                )
//            }
//        }
//    }
//}
//
//// 媒體選擇器助手
//struct MediaPickerHelper: UIViewControllerRepresentable {
//    @ObservedObject var mediaManager: MultiMediaManager
//    @Binding var isPresented: Bool
//    var sourceType: UIImagePickerController.SourceType
//    var mediaTypes: [String] = ["public.image", "public.movie"]
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.mediaTypes = mediaTypes
//        picker.delegate = context.coordinator
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
//        let parent: MediaPickerHelper
//        
//        init(_ parent: MediaPickerHelper) {
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
//                    parent.mediaManager.addImage(image)
//                    
//                    if picker.sourceType == .camera {
//                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    }
//                }
//            } else if mediaType == "public.movie" {
//                // 處理影片
//                if let videoURL = info[.mediaURL] as? URL {
//                    parent.mediaManager.addVideo(from: videoURL)
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
//
import SwiftUI
import PhotosUI
import AVFoundation
import CoreData

// 定義媒體項目結構
struct MediaItem: Identifiable, Equatable {
    var id = UUID()
    var type: MediaType
    var imageData: Data?
    var videoURL: URL?
    var thumbnailImage: UIImage?
    var localURL: URL?
    
    // 用於支援Equatable協議
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 生成縮略圖
    mutating func generateThumbnail() {
        if type == .image, let imageData = imageData {
            thumbnailImage = UIImage(data: imageData)
        } else if type == .video, let videoURL = videoURL ?? localURL {
            thumbnailImage = VideoUtils.generateThumbnail(from: videoURL)
        }
    }
}

// 媒體類型枚舉
enum MediaType: String, Codable {
    case image
    case video
    case audio
}

// 多媒體管理器
class MultiMediaManager: ObservableObject {
    @Published var mediaItems: [MediaItem] = []
    @Published var isLoading: Bool = false
    
    // 清除所有媒體項目
    func clearAll() {
        mediaItems.removeAll()
    }
    
    // 添加圖片
    func addImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        var newItem = MediaItem(type: .image, imageData: imageData)
        newItem.generateThumbnail()
        
        DispatchQueue.main.async {
            self.mediaItems.append(newItem)
        }
    }
    
    // 添加影片
    func addVideo(from url: URL) {
        var newItem = MediaItem(type: .video, videoURL: url)
        newItem.generateThumbnail()
        
        DispatchQueue.main.async {
            self.mediaItems.append(newItem)
        }
    }
    
    // 移除指定媒體項目
    func removeItem(at index: Int) {
        guard index < mediaItems.count else { return }
        mediaItems.remove(at: index)
    }
    
    // 移除指定媒體項目（通過ID）
    func removeItem(withID id: UUID) {
        if let index = mediaItems.firstIndex(where: { $0.id == id }) {
            mediaItems.remove(at: index)
        }
    }
    
    // 保存媒體文件到本地目錄，返回保存後的URLs
    func saveMediaItems() -> [URL] {
        var savedURLs: [URL] = []
        
        for (index, item) in mediaItems.enumerated() {
            if item.type == .image, let imageData = item.imageData {
                let fileName = "media_image_\(Date().timeIntervalSince1970)_\(index).jpg"
                let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL)
                    print("保存圖片成功: \(fileURL.path)")
                    savedURLs.append(fileURL)
                } catch {
                    print("保存圖片失敗: \(error)")
                }
            } else if item.type == .video, let videoURL = item.videoURL {
                if let savedURL = VideoUtils.copyVideoToDocuments(from: videoURL) {
                    print("保存視頻成功: \(savedURL.path)")
                    savedURLs.append(savedURL)
                }
            }
        }
        
        return savedURLs
    }
    
    // 從CoreData實體中加載媒體
    func loadFromURLStrings(_ urlStrings: [String]) {
        print("MultiMediaManager: 開始加載 \(urlStrings.count) 個媒體項目")
        mediaItems.removeAll()
        
        for (index, urlString) in urlStrings.enumerated() {
            print("處理 URL \(index): \(urlString)")
            guard let url = URL(string: urlString) else {
                print("無效的URL字符串: \(urlString)")
                continue
            }
            
            let pathExtension = url.pathExtension.lowercased()
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("檢查文件 \(url.lastPathComponent), 擴展名: \(pathExtension), 存在: \(fileExists)")
            
            if !fileExists {
                print("文件不存在: \(url.path)")
                continue
            }
            
            if ["jpg", "jpeg", "png"].contains(pathExtension) {
                // 處理圖片
                do {
                    print("讀取圖片數據...")
                    let imageData = try Data(contentsOf: url)
                    print("圖片數據大小: \(imageData.count) 字節")
                    
                    var newItem = MediaItem(type: .image, imageData: imageData, localURL: url)
                    newItem.generateThumbnail()
                    
                    if let thumbnail = newItem.thumbnailImage {
                        print("成功生成縮略圖: \(thumbnail.size.width) x \(thumbnail.size.height)")
                    } else {
                        print("警告: 無法生成縮略圖")
                    }
                    
                    mediaItems.append(newItem)
                    print("圖片項目添加成功")
                } catch {
                    print("加載圖片數據失敗: \(error)")
                }
            } else if ["mp4", "mov", "m4v"].contains(pathExtension) {
                print("處理視頻...")
                // 處理影片
                var newItem = MediaItem(type: .video, videoURL: nil, localURL: url)
                newItem.generateThumbnail()
                
                if let thumbnail = newItem.thumbnailImage {
                    print("成功生成視頻縮略圖: \(thumbnail.size.width) x \(thumbnail.size.height)")
                } else {
                    print("警告: 無法生成視頻縮略圖")
                }
                
                mediaItems.append(newItem)
                print("視頻項目添加成功")
            } else {
                print("不支持的文件類型: \(pathExtension)")
            }
        }
        
        print("媒體加載完成，共 \(mediaItems.count) 個項目")
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
struct MediaItemView: View {
    let item: MediaItem
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 媒體內容
            if let thumbnail = item.thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        // 視頻播放圖標
                        item.type == .video ?
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                            : nil
                    )
                    .onTapGesture {
                        onTap()
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(8)
                    .overlay(
                        Text(item.type == .video ? "影片" : "圖片")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
                    .onTapGesture {
                        onTap()
                    }
            }

            // 刪除按鈕
            Button(action: {
                showDeleteConfirm = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .padding(5)
            }
            .alert(isPresented: $showDeleteConfirm) {
                Alert(
                    title: Text("確認刪除"),
                    message: Text("你確定要刪除此媒體嗎？"),
                    primaryButton: .destructive(Text("刪除")) {
                        onDelete()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
    }
}


//// 媒體選擇器助手
struct MediaPickerHelper: UIViewControllerRepresentable {
    @ObservedObject var mediaManager: MultiMediaManager
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    var mediaTypes: [String] = ["public.image", "public.movie"]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MediaPickerHelper

        init(_ parent: MediaPickerHelper) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 檢查媒體類型
            let mediaType = info[.mediaType] as! String

            if mediaType == "public.image" {
                // 處理照片
                if let image = info[.originalImage] as? UIImage {
                    parent.mediaManager.addImage(image)

                    if picker.sourceType == .camera {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
            } else if mediaType == "public.movie" {
                // 處理影片
                if let videoURL = info[.mediaURL] as? URL {
                    parent.mediaManager.addVideo(from: videoURL)

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

            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct MediaGridView: View {
    @ObservedObject var mediaManager: MultiMediaManager
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    @State private var showingMediaPicker = false
    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingMediaSourceOptions = false
    @State private var showingVideoPlayer = false
    @State private var selectedVideoURL: URL?
    @State private var selectedImageForFullScreen: UIImage?
    @State private var showingFullScreenImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("媒體檔案").font(.headline)

            // 媒體網格
            if !mediaManager.mediaItems.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(mediaManager.mediaItems) { item in
                            MediaItemView(item: item) {
                                // 點擊動作
                                if item.type == .video, let url = item.videoURL {
                                    selectedVideoURL = url
                                    showingVideoPlayer = true
                                } else if item.type == .image, let image = item.thumbnailImage {
                                    selectedImageForFullScreen = image
                                    showingFullScreenImage = true
                                }
                            } onDelete: {
                                // 刪除動作
                                mediaManager.removeItem(withID: item.id)
                            }
                        }

                        // 添加媒體按鈕
                        Button(action: {
                            showingMediaSourceOptions = true
                        }) {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                Text("添加")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(height: 250)
            } else {
                // 無媒體時的添加按鈕
                Button(action: {
                    showingMediaSourceOptions = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.blue)
                        Text("添加照片或影片")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .actionSheet(isPresented: $showingMediaSourceOptions) {
            ActionSheet(
                title: Text("選擇媒體來源"),
                buttons: [
                    .default(Text("拍照")) {
                        mediaPickerSourceType = .camera
                        showingMediaPicker = true
                    },
                    .default(Text("錄製影片")) {
                        mediaPickerSourceType = .camera
                        showingMediaPicker = true
                    },
                    .default(Text("從相簿選擇")) {
                        mediaPickerSourceType = .photoLibrary
                        showingMediaPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingMediaPicker) {
            MediaPickerHelper(mediaManager: mediaManager, isPresented: $showingMediaPicker, sourceType: mediaPickerSourceType)
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let url = selectedVideoURL {
                VideoPlayerView(url: url)
            }
        }
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let image = selectedImageForFullScreen {
                FullScreenImageView(image: image, isPresented: $showingFullScreenImage)
            }
        }
    }
}



// CoreData擴展 - 為實體添加媒體URLs存儲功能
extension NSManagedObject {
    // 設置媒體URLs
    func setMediaURLs(_ urls: [URL]) {
        let urlStrings = urls.map { $0.absoluteString }
        print("保存 \(urlStrings.count) 個媒體URL到CoreData")
        if self.responds(to: NSSelectorFromString("mediaURLs")) {
            self.setValue(urlStrings, forKey: "mediaURLs")
        }
    }
    
    // 獲取媒體URLs
    func getMediaURLs() -> [String] {
        if let urlStrings = self.value(forKey: "mediaURLs") as? [String] {
            print("從CoreData獲取到 \(urlStrings.count) 個媒體URL")
            return urlStrings
        }
        print("CoreData中沒有找到媒體URL")
        return []
    }
}
