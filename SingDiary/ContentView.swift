//
//  ContentView.swift
//  SingDiary
//
//  Created by 曾浩儀 on 2025/4/16.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    Label("日記", systemImage: "book")
                }
            LessonsView()
                .tabItem {
                    Label("課堂", systemImage: "graduationcap")
                }
            PracticeProgressView()  // 已修改使用新名稱
                .tabItem {
                    Label("進度", systemImage: "chart.bar")
                }
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
