import SwiftUI
import CoreData

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PracticeEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<PracticeEntry>
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: PracticeEntry?

    var body: some View {
        NavigationView {
            VStack {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "沒有練習記錄",
                        systemImage: "music.note",
                        description: Text("點擊 + 按鈕新增第一筆練習紀錄")
                    )
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: PracticeDetailView(entry: entry)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(entry.songTitle ?? "（無標題）")
                                            .font(.headline)
                                        if entry.isFavorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    Text("⏱️ \(entry.durationMinutes) 分鐘")
                                        .font(.subheadline)
                                    
                                    HStack {
                                        if let mood = entry.mood, !mood.isEmpty {
                                            Text(mood)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(entry.date ?? Date(), style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showingDeleteAlert = true
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                                
                                Button {
                                    toggleFavorite(entry)
                                } label: {
                                    Label(entry.isFavorite ? "取消收藏" : "收藏",
                                          systemImage: entry.isFavorite ? "star.slash" : "star")
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "搜尋歌曲或心情")
                }
            }
            .navigationTitle("練習日記")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddPracticeView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .alert("確認刪除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("刪除", role: .destructive) {
                    if let entry = entryToDelete {
                        deleteEntry(entry)
                    }
                }
            } message: {
                Text("確定要刪除這筆練習紀錄嗎？此操作無法復原。")
            }
        }
    }
    
    private var filteredEntries: [PracticeEntry] {
        if searchText.isEmpty {
            return Array(entries)
        } else {
            return entries.filter { entry in
                let title = entry.songTitle?.lowercased() ?? ""
                let mood = entry.mood?.lowercased() ?? ""
                let notes = entry.notes?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                
                return title.contains(searchLower) ||
                       mood.contains(searchLower) ||
                       notes.contains(searchLower)
            }
        }
    }
    
    private func toggleFavorite(_ entry: PracticeEntry) {
        withAnimation {
            entry.isFavorite.toggle()
            try? viewContext.save()
        }
    }
    
    private func deleteEntry(_ entry: PracticeEntry) {
        withAnimation {
            viewContext.delete(entry)
            try? viewContext.save()
        }
    }
}
