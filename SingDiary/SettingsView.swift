import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("使用者資訊")) {
                    TextField("暱稱", text: $userName)
                }
                
                Section(header: Text("資料管理")) {
                    Button("匯出備份") {
                        // TODO: 加上匯出功能
                    }
                    Button("清除所有資料") {
                        // TODO: 加上清除功能
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("設定")
        }
    }
}
