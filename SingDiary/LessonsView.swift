import SwiftUI
import CoreData

struct LessonsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LessonNote.date, ascending: false)],
        animation: .default)
    private var lessons: FetchedResults<LessonNote>
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var lessonToDelete: LessonNote?

    var body: some View {
        NavigationView {
            VStack {
                if lessons.isEmpty {
                    ContentUnavailableView(
                        "沒有課堂筆記",
                        systemImage: "book.closed",
                        description: Text("點擊 + 按鈕新增第一筆課堂筆記")
                    )
                } else {
                    List {
                        ForEach(filteredLessons) { note in
                            NavigationLink(destination: LessonDetailView(note: note)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(note.teacher ?? "未知老師")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(note.date ?? Date(), style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // 顯示筆記內容預覽
                                    Text(note.content ?? "（無筆記內容）")
                                        .lineLimit(1)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    // 如果有回家作業，則顯示
                                    if let homework = note.homework, !homework.isEmpty {
                                        Text("作業: \(homework)")
                                            .lineLimit(1)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    lessonToDelete = note
                                    showingDeleteAlert = true
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "搜尋筆記")
                }
            }
            .navigationTitle("課堂筆記")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddLessonView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .alert("確認刪除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("刪除", role: .destructive) {
                    if let note = lessonToDelete {
                        deleteLesson(note)
                    }
                }
            } message: {
                Text("確定要刪除這筆課堂筆記嗎？此操作無法復原。")
            }
        }
    }
    
    private var filteredLessons: [LessonNote] {
        if searchText.isEmpty {
            return Array(lessons)
        } else {
            return lessons.filter { note in
                let content = note.content?.lowercased() ?? ""
                let teacher = note.teacher?.lowercased() ?? ""
                let homework = note.homework?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                
                return content.contains(searchLower) ||
                       teacher.contains(searchLower) ||
                       homework.contains(searchLower)
            }
        }
    }
    
    private func deleteLesson(_ note: LessonNote) {
        viewContext.delete(note)
        do {
            try viewContext.save()
        } catch {
            print("刪除筆記時發生錯誤：\(error)")
        }
    }
}
