//import SwiftUI
//import CoreData
//import UIKit
//import AVKit
//
//// 定義一個枚舉來管理不同類型的 sheet
//enum ActiveSheet: Identifiable {
//    case mediaPicker
//    case videoPlayer
//    
//    var id: Int {
//        hashValue
//    }
//}
//
//struct EditPracticeView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//    
//    @ObservedObject var entry: PracticeEntry
//    
//    @State private var songTitle: String
//    @State private var durationMinutes: Int16
//    @State private var mood: String
//    @State private var notes: String
//    @State private var isFavorite: Bool
//    @State private var date: Date
//    @State private var imageURL: URL?
//    @State private var videoURL: URL?
//    @State private var selectedImage: UIImage?
//    @State private var selectedVideoURL: URL?
//    @State private var mediaPickerSourceType: UIImagePickerController.SourceType = .photoLibrary
//    @State private var showingMediaSourceOptions = false
//    @State private var mediaType: String? // "image" 或 "video"
//    
//    // 使用單一 state 管理 sheet 顯示
//    @State private var activeSheet: ActiveSheet?
//    
//    init(entry: PracticeEntry) {
//        self.entry = entry
//        
//        // 初始化State變數
//        _songTitle = State(initialValue: entry.songTitle ?? "")
//        _durationMinutes = State(initialValue: entry.durationMinutes)
//        _mood = State(initialValue: entry.mood ?? "")
//        _notes = State(initialValue: entry.notes ?? "")
//        _isFavorite = State(initialValue: entry.isFavorite)
//        _date = State(initialValue: entry.date ?? Date())
//        _imageURL = State(initialValue: entry.imageURL)
//        _videoURL = State(initialValue: entry.videoURL)
//        _mediaType = State(initialValue: entry.mediaType)
//    }
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
//                if mediaType == "image" {
//                    // 照片顯示
//                    if let url = imageURL, let image = loadImageFromURL(url) {
//                        VStack {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(8)
//                            
//                            HStack {
//                                Button(action: {
//                                    showingMediaSourceOptions = true
//                                }) {
//                                    Text("更換媒體")
//                                        .foregroundColor(.blue)
//                                }
//                                
//                                Spacer()
//                                
//                                Button(action: {
//                                    imageURL = nil
//                                    videoURL = nil
//                                    selectedImage = nil
//                                    selectedVideoURL = nil
//                                    mediaType = nil
//                                }) {
//                                    Text("移除媒體")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
//                    } else if let image = selectedImage {
//                        VStack {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(8)
//                            
//                            HStack {
//                                Button(action: {
//                                    showingMediaSourceOptions = true
//                                }) {
//                                    Text("更換媒體")
//                                        .foregroundColor(.blue)
//                                }
//                                
//                                Spacer()
//                                
//                                Button(action: {
//                                    selectedImage = nil
//                                    selectedVideoURL = nil
//                                    mediaType = nil
//                                }) {
//                                    Text("移除媒體")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
//                    }
//                } else if mediaType == "video" {
//                    // 影片顯示
//                    if let url = videoURL ?? selectedVideoURL {
//                        VStack {
//                            // 影片縮略圖
//                            ZStack {
//                                if let thumbnail = VideoUtils.generateThumbnail(from: url) {
//                                    Image(uiImage: thumbnail)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .cornerRadius(8)
//                                } else {
//                                    Rectangle()
//                                        .fill(Color.gray.opacity(0.3))
//                                        .cornerRadius(8)
//                                        .overlay(
//                                            Text("影片縮略圖")
//                                                .foregroundColor(.secondary)
//                                        )
//                                }
//                                
//                                Button(action: {
//                                    activeSheet = .videoPlayer
//                                }) {
//                                    Image(systemName: "play.circle.fill")
//                                        .font(.system(size: 44))
//                                        .foregroundColor(.white)
//                                        .shadow(radius: 4)
//                                }
//                            }
//                            .frame(height: 200)
//                            
//                            HStack {
//                                Text(VideoUtils.formatDuration(VideoUtils.getVideoDuration(from: url)))
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                                
//                                Spacer()
//                                
//                                Button(action: {
//                                    showingMediaSourceOptions = true
//                                }) {
//                                    Text("更換媒體")
//                                        .foregroundColor(.blue)
//                                }
//                                
//                                Button(action: {
//                                    imageURL = nil
//                                    videoURL = nil
//                                    selectedImage = nil
//                                    selectedVideoURL = nil
//                                    mediaType = nil
//                                }) {
//                                    Text("移除媒體")
//                                        .foregroundColor(.red)
//                                }
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
//        .navigationTitle("編輯練習紀錄")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("儲存") {
//                    if let image = selectedImage {
//                        saveImage(image)
//                    }
//                    if let videoURL = selectedVideoURL {
//                        saveVideo(videoURL)
//                    }
//                    saveChanges()
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
//                        activeSheet = .mediaPicker
//                    },
//                    .default(Text("錄製影片")) {
//                        mediaPickerSourceType = .camera
//                        activeSheet = .mediaPicker
//                    },
//                    .default(Text("從相簿選擇")) {
//                        mediaPickerSourceType = .photoLibrary
//                        activeSheet = .mediaPicker
//                    },
//                    .cancel()
//                ]
//            )
//        }
//        .sheet(item: $activeSheet) { item in
//            switch item {
//            case .mediaPicker:
//                MediaPicker(selectedImage: $selectedImage,
//                            selectedVideoURL: $selectedVideoURL,
//                            isPresented: .constant(false), // 不再使用這個來關閉 sheet
//                            sourceType: mediaPickerSourceType)
//                    .onDisappear {
//                        // 設定媒體類型
//                        if selectedImage != nil {
//                            mediaType = "image"
//                        } else if selectedVideoURL != nil {
//                            mediaType = "video"
//                        }
//                        
//                        // 重要：清除 activeSheet 狀態
//                        activeSheet = nil
//                    }
//                
//            case .videoPlayer:
//                if let url = videoURL ?? selectedVideoURL {
//                    VideoPlayerView(url: url)
//                        .onDisappear {
//                            // 重要：清除 activeSheet 狀態
//                            activeSheet = nil
//                        }
//                }
//            }
//        }
//    }
//    
//    private func saveImage(_ image: UIImage) {
//        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
//        
//        let fileName = "practice_photo_\(Date().timeIntervalSince1970).jpg"
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//        
//        do {
//            try data.write(to: fileURL)
//            imageURL = fileURL
//            videoURL = nil
//        } catch {
//            print("保存圖片失敗: \(error)")
//        }
//    }
//    
//    private func saveVideo(_ videoURL: URL) {
//        if let savedURL = VideoUtils.copyVideoToDocuments(from: videoURL) {
//            self.videoURL = savedURL
//            self.imageURL = nil
//        }
//    }
//    
//    private func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//    
//    // 載入照片的方法
//    private func loadImageFromURL(_ url: URL) -> UIImage? {
//        do {
//            let imageData = try Data(contentsOf: url)
//            return UIImage(data: imageData)
//        } catch {
//            print("載入圖片失敗: \(error)")
//            return nil
//        }
//    }
//    
//    private func saveChanges() {
//        withAnimation {
//            entry.songTitle = songTitle
//            entry.durationMinutes = durationMinutes
//            entry.mood = mood
//            entry.notes = notes
//            entry.isFavorite = isFavorite
//            entry.date = date
//            entry.imageURL = imageURL
//            entry.videoURL = videoURL
//            entry.mediaType = mediaType
//            
//            do {
//                try viewContext.save()
//                // 確保 sheet 關閉
//                activeSheet = nil
//                // 關閉整個編輯視圖
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("更新失敗: \(error)")
//            }
//        }
//    }
//}

import SwiftUI
import CoreData
import UIKit
import AVKit


// 編輯練習視圖
struct EditPracticeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var entry: PracticeEntry
    
    // 基本練習資料
    @State private var songTitle: String
    @State private var date: Date
    @State private var durationMinutes: Int16
    @State private var mood: String
    @State private var notes: String
    @State private var skills: [String]
    
    // 媒體相關
    @StateObject private var mediaManager = MultiMediaManager()
    @State private var showingVideoRecorder = false
    @State private var showingAudioPlayer = false
    @StateObject private var audioRecorder = AudioRecorderService()
    @StateObject private var videoRecorder = VideoRecorderService()
    
    // 技能選項
    let availableSkills = [
        "高音技巧", "呼吸控制", "音準", "聲音共鳴",
        "咬字發音", "情感表達", "節奏感", "混聲技巧"
    ]
    
    init(entry: PracticeEntry) {
        self.entry = entry
        
        // 初始化State變數
        _songTitle = State(initialValue: entry.songTitle ?? "")
        _date = State(initialValue: entry.date ?? Date())
        _durationMinutes = State(initialValue: entry.durationMinutes)
        _mood = State(initialValue: entry.mood ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        _skills = State(initialValue: (entry.skills as? [String]) ?? [])
        
        // 設置錄音URL
        if let recordingURL = entry.recordingURL {
            self._audioRecorder = StateObject(wrappedValue: {
                let recorder = AudioRecorderService()
                recorder.recordingURL = recordingURL
                return recorder
            }())
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 基本資訊
                Group {
                    // 歌曲名稱
                    VStack(alignment: .leading) {
                        Text("歌曲名稱").font(.headline)
                        TextField("輸入您練習的歌曲名稱", text: $songTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 日期選擇
                    VStack(alignment: .leading) {
                        Text("練習日期").font(.headline)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    
                    // 練習時長
                    VStack(alignment: .leading) {
                        Text("練習時長").font(.headline)
                        Stepper("\(durationMinutes) 分鐘", value: $durationMinutes, in: 1...120)
                    }
                    
                    // 心情
                    VStack(alignment: .leading) {
                        Text("今日心情").font(.headline)
                        TextField("例如：放鬆、專注、有進步...", text: $mood)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // 收藏星號
                VStack(alignment: .leading) {
                    Toggle(isOn: Binding(
                        get: { entry.isFavorite },
                        set: { entry.isFavorite = $0 }
                    )) {
                        Label("加入收藏", systemImage: "star")
                    }
                }
                
                // 技能選擇
                VStack(alignment: .leading) {
                    Text("練習技能").font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 10) {
                        ForEach(availableSkills, id: \.self) { skill in
                            SkillToggleView(
                                skill: skill,
                                isSelected: skills.contains(skill),
                                onToggle: { selected in
                                    if selected {
                                        skills.append(skill)
                                    } else {
                                        skills.removeAll { $0 == skill }
                                    }
                                }
                            )
                        }
                    }
                }
                
                // 錄音功能
                VStack(alignment: .leading) {
                    Text("錄音功能").font(.headline)
                    
                    HStack {
                        if audioRecorder.isRecording {
                            Button(action: {
                                audioRecorder.stopRecording()
                            }) {
                                Label("停止錄音", systemImage: "stop.circle.fill")
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Text("錄音中: \(Int(audioRecorder.recordingDuration))秒")
                                .foregroundColor(.red)
                        } else if let url = audioRecorder.recordingURL {
                            Button(action: {
                                showingAudioPlayer = true
                            }) {
                                Label("播放錄音", systemImage: "play.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                audioRecorder.recordingURL = nil
                            }) {
                                Label("刪除", systemImage: "trash")
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        } else {
                            Button(action: {
                                audioRecorder.startRecording()
                            }) {
                                Label("開始錄音", systemImage: "mic.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // 影片錄製按鈕
                VStack(alignment: .leading) {
                    Text("錄製影片").font(.headline)
                    
                    Button(action: {
                        showingVideoRecorder = true
                    }) {
                        Label("打開相機錄製", systemImage: "video.circle.fill")
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // 多媒體管理
                VStack(alignment: .leading) {
                    MediaGridView(mediaManager: mediaManager)
                        .onAppear {
                            let urlStrings = entry.getMediaURLs()
                            mediaManager.loadFromURLStrings(urlStrings)
                        }
                }
                
                // 練習筆記
                VStack(alignment: .leading) {
                    Text("練習筆記").font(.headline)
                    TextEditor(text: $notes)
                        .frame(minHeight: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 20)
                }
                
                // 儲存按鈕
                Button(action: {
                    saveChanges()
                }) {
                    Text("儲存變更")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(songTitle.isEmpty)
            }
            .padding()
        }
        .navigationTitle("編輯練習")
        .fullScreenCover(isPresented: $showingVideoRecorder) {
            VideoRecorderView(videoRecorder: videoRecorder) { recordedURL in
                if let url = recordedURL {
                    mediaManager.addVideo(from: url)
                }
            }
        }
        .sheet(isPresented: $showingAudioPlayer) {
            if let recordingURL = audioRecorder.recordingURL {
                AudioPlayerView(url: recordingURL)
            }
        }
    }
    
    private func saveChanges() {
        withAnimation {
            entry.songTitle = songTitle
            entry.date = date
            entry.durationMinutes = durationMinutes
            entry.mood = mood
            entry.notes = notes
            entry.skills = skills as NSObject
            
            // 儲存錄音文件
            if let audioURL = audioRecorder.recordingURL {
                entry.recordingURL = audioURL
            } else {
                entry.recordingURL = nil
            }
            
            // 儲存多個媒體檔案
            let savedMediaURLs = mediaManager.saveMediaItems()
            entry.setMediaURLs(savedMediaURLs)
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("儲存失敗: \(error)")
            }
        }
    }
}
