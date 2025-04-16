import SwiftUI
import CoreData

struct PracticeProgressView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PracticeEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<PracticeEntry>

    var totalMinutes: Int {
        entries.reduce(0) { $0 + Int($1.durationMinutes) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📊 本週總練習時間")
                    .font(.headline)
                Text("\(totalMinutes) 分鐘")
                    .font(.largeTitle)
                    .bold()
                
                // 更多統計項目未來可加上，例如技巧統計
                Spacer()
            }
            .padding()
            .navigationTitle("進度統計")
        }
    }
}
