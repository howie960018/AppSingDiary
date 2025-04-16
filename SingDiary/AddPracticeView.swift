//import SwiftUI
//import CoreData
//import UIKit
//import AVKit
//
//struct AddPracticeView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//    
//    @State private var songTitle = ""
//    @State private var durationMinutes: Int16 = 15
//    @State private var mood = ""
//    @State private var notes = ""
//    @State private var isFavorite = false
//    @State private var date = Date()
//    @State private var selectedImage: UIImage?
//    @State private var selectedVideoURL: URL?
//    @State private var showingMediaPicker = false
//    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
//    @State private var showingMediaSourceOptions = false
//    @State private var showingVideoPlayer = false
//    @State private var mediaType: String? // "image" 或 "video"
//    
//    var body: some View {
//        Form {
//            Section(header: Text("歌曲資訊")) {
//                TextField("歌曲名稱", text: $songTitle)
//                
//                Stepper("練習時間: \(durationMinutes) 分鐘", value: $durationMinutes, in: 1...180)
//                
//                Toggle("加入收藏", isOn: $isFavorite)
//                    .toggleStyle(SwitchToggleStyle(tint: .yellow))
//            }
//            
//            Section(header: Text("練習媒體")) {
//                if mediaType == "image", let image = selectedImage {
//                    // 照片顯示
//                    VStack {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .cornerRadius(8)
//                        
//                        HStack {
//                            Button(action: {
//                                showingMediaSourceOptions = true
//                            }) {
//                                Text("更換媒體")
//                                    .foregroundColor(.blue)
//                            }
//                            
//                            Spacer()
//                            
//                            Button(action: {
//                                selectedImage = nil
//                                selectedVideoURL = nil
//                                mediaType = nil
//                            }) {
//                                Text("移除媒體")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                } else if mediaType == "video", let url = selectedVideoURL {
//                    // 影片顯示
//                    VStack {
//                        // 影片縮略圖
//                        ZStack {
//                            if let thumbnail = VideoUtils.generateThumbnail(from: url) {
//                                Image(uiImage: thumbnail)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .cornerRadius(8)
//                            } else {
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.3))
//                                    .cornerRadius(8)
//                                    .overlay(
//                                        Text("影片縮略圖")
//                                            .foregroundColor(.secondary)
//                                    )
//                            }
//                            
//                            Button(action: {
//                                showingVideoPlayer = true
//                            }) {
//                                Image(systemName: "play.circle.fill")
//                                    .font(.system(size: 44))
//                                    .foregroundColor(.white)
//                                    .shadow(radius: 4)
//                            }
//                        }
//                        .frame(height: 200)
//                        
//                        HStack {
//                            Text(VideoUtils.formatDuration(VideoUtils.getVideoDuration(from: url)))
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            
//                            Spacer()
//                            
//                            Button(action: {
//                                showingMediaSourceOptions = true
//                            }) {
//                                Text("更換媒體")
//                                    .foregroundColor(.blue)
//                            }
//                            
//                            Button(action: {
//                                selectedImage = nil
//                                selectedVideoURL = nil
//                                mediaType = nil
//                            }) {
//                                Text("移除媒體")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                } else {
//                    // 沒有媒體時顯示添加按鈕
//                    Button(action: {
//                        showingMediaSourceOptions = true
//                    }) {
//                        HStack {
//                            Image(systemName: "photo.on.rectangle.angled")
//                                .foregroundColor(.blue)
//                            Text("添加照片或影片")
//                        }
//                    }
//                }
//            }
//            
//            Section(header: Text("練習細節")) {
//                DatePicker("日期", selection: $date, displayedComponents: .date)
//                
//                TextField("心情", text: $mood)
//                    .autocapitalization(.none)
//                
//                VStack(alignment: .leading) {
//                    Text("筆記")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    TextEditor(text: $notes)
//                        .frame(minHeight: 100)
//                }
//            }
//        }
//        .navigationTitle("新增練習紀錄")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("儲存") {
//                    addPractice()
//                }
//                .disabled(songTitle.isEmpty)
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
//            MediaPicker(selectedImage: $selectedImage,
//                        selectedVideoURL: $selectedVideoURL,
//                        isPresented: $showingMediaPicker,
//                        sourceType: mediaPickerSourceType)
//                .onDisappear {
//                    // 設定媒體類型
//                    if selectedImage != nil {
//                        mediaType = "image"
//                    } else if selectedVideoURL != nil {
//                        mediaType = "video"
//                    }
//                }
//        }
//        .fullScreenCover(isPresented: $showingVideoPlayer) {
//            if let url = selectedVideoURL {
//                VideoPlayerView(url: url)
//            }
//        }
//    }
//    
//    private func saveImage(_ image: UIImage) -> URL? {
//        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
//        
//        let fileName = "practice_photo_\(Date().timeIntervalSince1970).jpg"
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//        
//        do {
//            try data.write(to: fileURL)
//            return fileURL
//        } catch {
//            print("保存圖片失敗: \(error)")
//            return nil
//        }
//    }
//    
//    private func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//    
//    private func addPractice() {
//        let newEntry = PracticeEntry(context: viewContext)
//        newEntry.songTitle = songTitle
//        newEntry.durationMinutes = durationMinutes
//        newEntry.mood = mood
//        newEntry.notes = notes
//        newEntry.isFavorite = isFavorite
//        newEntry.date = date
//        newEntry.mediaType = mediaType
//        
//        // 保存媒體（照片或影片）
//        if let image = selectedImage {
//            newEntry.imageURL = saveImage(image)
//        } else if let videoURL = selectedVideoURL {
//            newEntry.videoURL = VideoUtils.copyVideoToDocuments(from: videoURL)
//        }
//        
//        do {
//            try viewContext.save()
//            presentationMode.wrappedValue.dismiss()
//        } catch {
//            print("儲存失敗: \(error)")
//        }
//    }
//}
import SwiftUI
import CoreData
import UIKit
import AVKit

struct AddPracticeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    // 基本資訊
    @State private var songTitle = ""
    @State private var date = Date()
    @State private var durationMinutes: Int16 = 15
    @State private var mood = ""
    @State private var notes = ""
    @State private var skills: [String] = []

    // 媒體（單一圖片或影片）
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var showingMediaPicker = false
    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingMediaSourceOptions = false
    @State private var showingVideoPlayer = false
    @State private var mediaType: String? // "image" 或 "video"

    // 錄音
    @StateObject private var audioRecorder = AudioRecorderService()
    @State private var showingAudioPlayer = false

    let availableSkills = ["高音技巧", "呼吸控制", "音準", "聲音共鳴", "咬字發音", "情感表達", "節奏感", "混聲技巧"]

    var body: some View {
        Form {
            Section(header: Text("歌曲資訊")) {
                TextField("輸入歌曲名稱", text: $songTitle)
                DatePicker("練習日期", selection: $date, displayedComponents: .date)
                Stepper("練習時間: \(durationMinutes) 分鐘", value: $durationMinutes, in: 1...180)
                TextField("心情", text: $mood)
            }

            Section(header: Text("技能標籤")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(availableSkills, id: \.self) { skill in
                        SkillToggleView(skill: skill,
                                        isSelected: skills.contains(skill),
                                        onToggle: { selected in
                            if selected {
                                skills.append(skill)
                            } else {
                                skills.removeAll { $0 == skill }
                            }
                        })
                    }
                }
            }

            Section(header: Text("練習媒體")) {
                if mediaType == "image", let image = selectedImage {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)

                        HStack {
                            Button("更換媒體") {
                                showingMediaSourceOptions = true
                            }
                            Spacer()
                            Button("移除媒體") {
                                selectedImage = nil
                                selectedVideoURL = nil
                                mediaType = nil
                            }.foregroundColor(.red)
                        }
                    }
                } else if mediaType == "video", let url = selectedVideoURL {
                    VStack {
                        ZStack {
                            if let thumbnail = VideoUtils.generateThumbnail(from: url) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                            }
                            Button {
                                showingVideoPlayer = true
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 200)

                        HStack {
                            Text(VideoUtils.formatDuration(VideoUtils.getVideoDuration(from: url)))
                                .font(.caption)
                            Spacer()
                            Button("更換媒體") {
                                showingMediaSourceOptions = true
                            }
                            Button("移除媒體") {
                                selectedImage = nil
                                selectedVideoURL = nil
                                mediaType = nil
                            }.foregroundColor(.red)
                        }
                    }
                } else {
                    Button(action: {
                        showingMediaSourceOptions = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("添加照片或影片")
                        }
                    }
                }
            }

            Section(header: Text("錄音")) {
                if audioRecorder.isRecording {
                    Button("停止錄音") {
                        audioRecorder.stopRecording()
                    }.foregroundColor(.red)
                } else if let url = audioRecorder.recordingURL {
                    Button("播放錄音") {
                        showingAudioPlayer = true
                    }
                    Button("刪除錄音") {
                        audioRecorder.recordingURL = nil
                    }.foregroundColor(.red)
                } else {
                    Button("開始錄音") {
                        audioRecorder.startRecording()
                    }
                }
            }

            Section(header: Text("練習筆記")) {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle("新增練習記錄")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("儲存") {
                    savePractice()
                }.disabled(songTitle.isEmpty)
            }
        }
        .actionSheet(isPresented: $showingMediaSourceOptions) {
            ActionSheet(title: Text("選擇媒體來源"), buttons: [
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
            ])
        }
        .sheet(isPresented: $showingMediaPicker) {
            MediaPicker(selectedImage: $selectedImage,
                        selectedVideoURL: $selectedVideoURL,
                        isPresented: $showingMediaPicker,
                        sourceType: mediaPickerSourceType)
                .onDisappear {
                    if selectedImage != nil {
                        mediaType = "image"
                    } else if selectedVideoURL != nil {
                        mediaType = "video"
                    }
                }
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let url = selectedVideoURL {
                VideoPlayerView(url: url)
            }
        }
        .sheet(isPresented: $showingAudioPlayer) {
            if let url = audioRecorder.recordingURL {
                AudioPlayerView(url: url)
            }
        }
    }

    private func saveImage(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "practice_photo_\(Date().timeIntervalSince1970).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("圖片儲存失敗: \(error)")
            return nil
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func savePractice() {
        let newEntry = PracticeEntry(context: viewContext)
        newEntry.songTitle = songTitle
        newEntry.date = date
        newEntry.durationMinutes = durationMinutes
        newEntry.mood = mood
        newEntry.notes = notes
        newEntry.skills = skills as NSObject
        newEntry.mediaType = mediaType

        if let audioURL = audioRecorder.recordingURL {
            newEntry.recordingURL = audioURL
        }

        if let image = selectedImage {
            newEntry.imageURL = saveImage(image)
        } else if let videoURL = selectedVideoURL {
            newEntry.videoURL = VideoUtils.copyVideoToDocuments(from: videoURL)
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("儲存失敗: \(error)")
        }
    }
}

// MARK: - 技能切換按鈕

struct SkillToggleView: View {
    let skill: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack {
                Text(skill)
                    .font(.subheadline)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
