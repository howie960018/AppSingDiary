import SwiftUI
import CoreData
import UIKit
import AVKit

struct LessonDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var note: LessonNote
    @State private var showingEditSheet = false
    @State private var showFullScreenImage = false
    @State private var showingVideoPlayer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 標題部分 (老師名稱)
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.teacher ?? "未知老師")
                        .font(.title)
                        .bold()
                    
                    Text(note.date?.formatted(date: .long, time: .omitted) ?? "未知日期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // 媒體顯示部分 (照片或影片)
                if let mediaType = note.mediaType {
                    if mediaType == "image", let imageURL = note.imageURL, let image = loadImageFromURL(imageURL) {
                        // 照片顯示
                        VStack(alignment: .leading, spacing: 8) {
                            Text("課堂照片")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showFullScreenImage = true
                            }) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    } else if mediaType == "video", let videoURL = note.videoURL {
                        // 影片顯示
                        VStack(alignment: .leading, spacing: 8) {
                            Text("課堂影片")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // 影片縮略圖
                            ZStack {
                                if let thumbnail = VideoUtils.generateThumbnail(from: videoURL) {
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
                            
                            Text(VideoUtils.formatDuration(VideoUtils.getVideoDuration(from: videoURL)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // 筆記內容
                VStack(alignment: .leading, spacing: 16) {
                    Text("上課心得筆記")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(note.content ?? "（無筆記內容）")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // 回家作業
                VStack(alignment: .leading, spacing: 16) {
                    Text("回家作業")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let homework = note.homework, !homework.isEmpty {
                        Text(homework)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("（無作業）")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("課堂詳情")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("編輯")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditLessonView(note: note)
                    .navigationTitle("編輯筆記")
                    .navigationBarItems(leading: Button("取消") {
                        showingEditSheet = false
                    })
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let imageURL = note.imageURL, let image = loadImageFromURL(imageURL) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showFullScreenImage = false
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
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let videoURL = note.videoURL {
                VideoPlayerView(url: videoURL)
            }
        }
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
}
