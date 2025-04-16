//
//  Persistence.swift
//  SingDiary
//
//  Created by 曾浩儀 on 2025/4/16.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 創建範例練習紀錄
        for i in 0..<5 {
            let newEntry = PracticeEntry(context: viewContext)
            newEntry.date = Date().addingTimeInterval(-Double(i * 86400)) // 每筆隔一天
            newEntry.songTitle = "範例歌曲 \(i+1)"
            newEntry.durationMinutes = Int16(15 + (i * 5))
            newEntry.mood = ["開心", "專注", "疲累", "放鬆", "挫折"][i % 5]
            newEntry.notes = "這是一個練習筆記範例..."
            newEntry.isFavorite = (i % 3 == 0)
        }
        
        // 創建範例課堂筆記
        for i in 0..<3 {
            let newLesson = LessonNote(context: viewContext)
            newLesson.date = Date().addingTimeInterval(-Double(i * 7 * 86400)) // 每筆隔一週
            newLesson.teacher = "王老師"
            newLesson.content = "今天學習了呼吸和發聲的基本技巧。老師提醒要保持正確的姿勢和放鬆喉嚨。"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SingDiary")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
