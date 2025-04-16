//import SwiftUI
//import CoreData
//import AVKit
//import UIKit

//struct PracticeDetailView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @ObservedObject var entry: PracticeEntry
//    @StateObject private var mediaManager = MultiMediaManager()
//    @State private var showingEditSheet = false
//    @State private var showingVideoPlayer = false
//    @State private var showingAudioPlayer = false
//    @State private var selectedVideoURL: URL?
//    @State private var showingFullScreenImage = false
//    @State private var selectedFullScreenImage: UIImage?
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // 標題部分
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Text(entry.songTitle ?? "未命名練習")
//                            .font(.title)
//                            .bold()
//                        
//                        Spacer()
//                        
//                        if entry.isFavorite {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.yellow)
//                                .font(.title2)
//                        }
//                    }
//                    
//                    Text(entry.date?.formatted(date: .long, time: .omitted) ?? "未知日期")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    HStack {
//                        Label("\(entry.durationMinutes) 分鐘", systemImage: "clock")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        
//                        if let mood = entry.mood, !mood.isEmpty {
//                            Text("•")
//                                .foregroundColor(.secondary)
//                            
//                            Text(mood)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                
//                // 技能標籤
//                if let skills = entry.skills as? [String], !skills.isEmpty {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("練習技能")
//                            .font(.headline)
//                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(skills, id: \.self) { skill in
//                                    Text(skill)
//                                        .font(.subheadline)
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 6)
//                                        .background(Color.blue.opacity(0.1))
//                                        .foregroundColor(.blue)
//                                        .cornerRadius(16)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                // 媒體文件
//                if mediaManager.mediaItems.count > 0 {
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("媒體文件")
//                            .font(.headline)
//                            .padding(.horizontal)
//                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(mediaManager.mediaItems) { item in
//                                    MediaPreviewThumbnail(item: item) {
//                                        // 點擊事件
//                                        if item.type == .video, let url = item.videoURL ?? item.localURL {
//                                            selectedVideoURL = url
//                                            showingVideoPlayer = true
//                                            print("準備播放視頻: \(url.absoluteString)")
//                                        } else if item.type == .image, let image = item.thumbnailImage {
//                                            selectedFullScreenImage = image
//                                            showingFullScreenImage = true
//                                            print("準備顯示圖片")
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//                
//                // 錄音播放
//                if let recordingURL = entry.recordingURL {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("錄音")
//                            .font(.headline)
//                        
//                        Button(action: {
//                            showingAudioPlayer = true
//                        }) {
//                            HStack {
//                                Image(systemName: "play.circle.fill")
//                                    .font(.title2)
//                                    .foregroundColor(.blue)
//                                
//                                Text("播放練習錄音")
//                                    .foregroundColor(.primary)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Divider()
//                    .padding(.horizontal)
//                
//                // 練習筆記
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("練習筆記")
//                        .font(.headline)
//                    
//                    if let notes = entry.notes, !notes.isEmpty {
//                        Text(notes)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    } else {
//                        Text("無筆記")
//                            .foregroundColor(.secondary)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .padding(.vertical)
//        }
//        .navigationTitle("練習詳情")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    showingEditSheet = true
//                }) {
//                    Text("編輯")
//                }
//            }
//        }
//        .onAppear {
//            loadMediaItems()
//        }
//        .sheet(isPresented: $showingAudioPlayer) {
//            if let recordingURL = entry.recordingURL {
//                AudioPlayerView(url: recordingURL)
//            }
//        }
//        .fullScreenCover(isPresented: $showingVideoPlayer) {
//            if let url = selectedVideoURL {
//                VideoPlayerView(url: url)
//            }
//        }
//        .fullScreenCover(isPresented: $showingFullScreenImage) {
//            if let image = selectedFullScreenImage {
//                FullScreenImageView(image: image, isPresented: $showingFullScreenImage)
//            }
//        }
//        .sheet(isPresented: $showingEditSheet) {
//            NavigationView {
//                EditPracticeView(entry: entry)
//                    .navigationTitle("編輯練習")
//                    .navigationBarItems(leading: Button("取消") {
//                        showingEditSheet = false
//                    })
//                    .onDisappear {
//                        // 重新加載媒體項目以反映可能的更改
//                        loadMediaItems()
//                    }
//            }
//        }
//    }
//    
//    private func loadMediaItems() {
//        let urlStrings = entry.getMediaURLs()
//        print("加載 \(urlStrings.count) 個媒體項目")
//        mediaManager.loadFromURLStrings(urlStrings)
//    }
//}
//
//// 媒體預覽縮略圖
//struct MediaPreviewThumbnail: View {
//    let item: MediaItem
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            ZStack {
//                if let thumbnail = item.thumbnailImage {
//                    Image(uiImage: thumbnail)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 120, height: 160)
//                        .cornerRadius(8)
//                        .clipped()
//                } else {
//                    Rectangle()
//                        .fill(Color.gray)
//                        .frame(width: 120, height: 160)
//                        .cornerRadius(8)
//                }
//                
//                if item.type == .video {
//                    Image(systemName: "play.fill")
//                        .font(.title)
//                        .foregroundColor(.white)
//                        .shadow(radius: 3)
//                }
//            }
//        }
//    }
//}
//
//
//
import SwiftUI
import CoreData
import AVKit

struct PracticeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var entry: PracticeEntry

    @State private var showingEditSheet = false
    @State private var showingVideoPlayer = false
    @State private var showingAudioPlayer = false
    @State private var selectedVideoURL: URL?
    @State private var showingFullScreenImage = false
    @State private var selectedFullScreenImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // 標題資訊
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.songTitle ?? "未命名練習")
                            .font(.title)
                            .bold()

                        Spacer()

                        if entry.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                        }
                    }

                    Text(entry.date?.formatted(date: .long, time: .omitted) ?? "未知日期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Label("\(entry.durationMinutes) 分鐘", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let mood = entry.mood, !mood.isEmpty {
                            Text("•").foregroundColor(.secondary)
                            Text(mood)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // 技能標籤
                if let skills = entry.skills as? [String], !skills.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("練習技能")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 單一媒體（圖片或影片）
                if let mediaType = entry.mediaType {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("練習媒體")
                            .font(.headline)
                            .padding(.horizontal)

                        if mediaType == "image", let imageURL = entry.imageURL {
                            Button {
                                if let image = loadImageFromURL(imageURL) {
                                    selectedFullScreenImage = image
                                    showingFullScreenImage = true
                                }
                            } label: {
                                if let image = loadImageFromURL(imageURL) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                } else {
                                    Text("無法載入圖片")
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }
                            }

                        } else if mediaType == "video", let videoURL = entry.videoURL {
                            Button {
                                selectedVideoURL = videoURL
                                showingVideoPlayer = true
                            } label: {
                                ZStack {
                                    if let thumbnail = VideoUtils.generateThumbnail(from: videoURL) {
                                        Image(uiImage: thumbnail)
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(8)
                                            .padding(.horizontal)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 200)
                                            .cornerRadius(8)
                                            .overlay(Text("無法產生縮圖").foregroundColor(.white))
                                            .padding(.horizontal)
                                    }

                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                }
                            }
                        }
                    }
                }

                // 錄音播放
                if let recordingURL = entry.recordingURL {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("錄音")
                            .font(.headline)

                        Button {
                            showingAudioPlayer = true
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("播放練習錄音")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }

                Divider().padding(.horizontal)

                // 練習筆記
                VStack(alignment: .leading, spacing: 16) {
                    Text("練習筆記")
                        .font(.headline)

                    if let notes = entry.notes, !notes.isEmpty {
                        Text(notes)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("無筆記")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("練習詳情")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編輯") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingAudioPlayer) {
            if let url = entry.recordingURL {
                AudioPlayerView(url: url)
            }
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let url = selectedVideoURL {
                VideoPlayerView(url: url)
            }
        }
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let image = selectedFullScreenImage {
                FullScreenImageView(image: image, isPresented: $showingFullScreenImage)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditPracticeView(entry: entry)
                    .navigationTitle("編輯練習")
                    .navigationBarItems(leading: Button("取消") {
                        showingEditSheet = false
                    })
            }
        }
    }

    private func loadImageFromURL(_ url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print("載入圖片失敗: \(error)")
            return nil
        }
    }
}

// MARK: - 全螢幕圖片檢視

struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
