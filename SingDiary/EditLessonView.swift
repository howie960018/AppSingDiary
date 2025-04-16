import SwiftUI
import CoreData
import UIKit
import AVKit

struct EditLessonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var note: LessonNote
    
    @State private var teacher: String
    @State private var content: String
    @State private var homework: String
    @State private var date: Date
    @State private var imageURL: URL?
    @State private var videoURL: URL?
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingMediaSourceOptions = false
    @State private var showingVideoPlayer = false
    @State private var showingMediaPicker = false
    @State private var mediaType: String? // "image" 或 "video"
    
    init(note: LessonNote) {
        self.note = note
        
        // 初始化State變數
        _teacher = State(initialValue: note.teacher ?? "")
        _content = State(initialValue: note.content ?? "")
        _homework = State(initialValue: note.homework ?? "")
        _date = State(initialValue: note.date ?? Date())
        _imageURL = State(initialValue: note.imageURL)
        _videoURL = State(initialValue: note.videoURL)
        _mediaType = State(initialValue: note.mediaType)
    }
    
    var body: some View {
        Form {
            Section(header: Text("老師")) {
                TextField("輸入老師姓名", text: $teacher)
            }
            
            Section(header: Text("日期")) {
                DatePicker("選擇日期", selection: $date, displayedComponents: .date)
            }
            
            Section(header: Text("課堂媒體")) {
                if mediaType == "image" {
                    // 照片顯示
                    if let url = imageURL, let image = loadImageFromURL(url) {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                            
                            HStack {
                                Button(action: {
                                    showingMediaSourceOptions = true
                                }) {
                                    Text("更換媒體")
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    imageURL = nil
                                    videoURL = nil
                                    selectedImage = nil
                                    selectedVideoURL = nil
                                    mediaType = nil
                                }) {
                                    Text("移除媒體")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } else if let image = selectedImage {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                            
                            HStack {
                                Button(action: {
                                    showingMediaSourceOptions = true
                                }) {
                                    Text("更換媒體")
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedImage = nil
                                    selectedVideoURL = nil
                                    mediaType = nil
                                }) {
                                    Text("移除媒體")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                } else if mediaType == "video" {
                    // 影片顯示
                    if let url = videoURL ?? selectedVideoURL {
                        VStack {
                            // 影片縮略圖
                            ZStack {
                                if let thumbnail = VideoUtils.generateThumbnail(from: url) {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                        .overlay(
                                            Text("影片縮略圖")
                                                .foregroundColor(.secondary)
                                        )
                                }
                                
                                Button(action: {
                                    showingVideoPlayer = true
                                }) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                }
                            }
                            .frame(height: 200)
                            
                            HStack {
                                Text(VideoUtils.formatDuration(VideoUtils.getVideoDuration(from: url)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingMediaSourceOptions = true
                                }) {
                                    Text("更換媒體")
                                        .foregroundColor(.blue)
                                }
                                
                                Button(action: {
                                    imageURL = nil
                                    videoURL = nil
                                    selectedImage = nil
                                    selectedVideoURL = nil
                                    mediaType = nil
                                }) {
                                    Text("移除媒體")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                } else {
                    // 沒有媒體時顯示添加按鈕
                    Button(action: {
                        showingMediaSourceOptions = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.blue)
                            Text("添加照片或影片")
                        }
                    }
                }
            }
            
            Section(header: Text("上課心得筆記")) {
                TextEditor(text: $content)
                    .frame(minHeight: 150)
            }
            
            Section(header: Text("回家作業")) {
                TextEditor(text: $homework)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("編輯筆記")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("儲存") {
                    if let image = selectedImage {
                        saveImage(image)
                    }
                    if let videoURL = selectedVideoURL {
                        saveVideo(videoURL)
                    }
                    saveChanges()
                }
                .disabled(teacher.isEmpty)
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
            MediaPicker(selectedImage: $selectedImage,
                       selectedVideoURL: $selectedVideoURL,
                       isPresented: $showingMediaPicker,
                       sourceType: mediaPickerSourceType)
                .onDisappear {
                    // 設定媒體類型
                    if selectedImage != nil {
                        mediaType = "image"
                    } else if selectedVideoURL != nil {
                        mediaType = "video"
                    }
                }
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let url = videoURL ?? selectedVideoURL {
                VideoPlayerView(url: url)
            }
        }
    }
    
    private func saveImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileName = "lesson_photo_\(Date().timeIntervalSince1970).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            imageURL = fileURL
            videoURL = nil
        } catch {
            print("保存圖片失敗: \(error)")
        }
    }
    
    private func saveVideo(_ videoURL: URL) {
        if let savedURL = VideoUtils.copyVideoToDocuments(from: videoURL) {
            self.videoURL = savedURL
            self.imageURL = nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 載入照片的方法
    private func loadImageFromURL(_ url: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print("載入圖片失敗: \(error)")
            return nil
        }
    }
    
    private func saveChanges() {
        withAnimation {
            note.teacher = teacher
            note.content = content
            note.homework = homework
            note.date = date
            note.imageURL = imageURL
            note.videoURL = videoURL
            note.mediaType = mediaType
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("更新失敗: \(error)")
            }
        }
    }
}
