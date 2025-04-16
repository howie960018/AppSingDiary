import SwiftUI

@main
struct SingDiaryApp: App {
    let persistenceController = PersistenceController.shared
    
    // 保存是否需要顯示權限視圖
    @AppStorage("hasShownPermissions") private var hasShownPermissions = false
    @State private var showPermissionsInfo = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                // 如果需要顯示權限視圖，則顯示
                if showPermissionsInfo {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            PermissionsInfoView(showPermissionsInfo: $showPermissionsInfo)
                        )
                }
            }
            .onAppear {
                if !hasShownPermissions {
                    // 稍微延遲顯示，避免影響啟動動畫
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPermissionsInfo = true
                        hasShownPermissions = true
                    }
                }
            }
        }
    }
}
