import SwiftUI
import AVFoundation

struct PermissionsInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showPermissionsInfo: Bool
    
    @State private var hasMicrophonePermission = false
    @State private var hasCameraPermission = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Text("歌唱練習日記需要取得這些權限")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    PermissionRow(
                        icon: "mic.fill",
                        title: "麥克風",
                        description: "錄製您練唱的聲音",
                        isGranted: hasMicrophonePermission
                    )
                    
                    PermissionRow(
                        icon: "video.fill",
                        title: "相機",
                        description: "錄製視頻以檢視您的演唱姿勢",
                        isGranted: hasCameraPermission
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("您可以在設定中隨時更改這些權限")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    requestPermissions()
                }) {
                    Text("授權使用")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("應用程式權限")
            .navigationBarItems(trailing: Button("跳過") {
                showPermissionsInfo = false
            })
            .onAppear {
                checkPermissions()
            }
        }
    }
    
    private func checkPermissions() {
        // 檢查麥克風權限
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasMicrophonePermission = true
        default:
            hasMicrophonePermission = false
        }
        
        // 檢查相機權限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasCameraPermission = true
        default:
            hasCameraPermission = false
        }
    }
    
    private func requestPermissions() {
        // 請求麥克風權限
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                hasMicrophonePermission = granted
                
                // 請求相機權限
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        hasCameraPermission = granted
                        
                        // 如果兩者都授權了，或者用戶已經做出了選擇，就關閉此視圖
                        if hasMicrophonePermission && hasCameraPermission {
                            showPermissionsInfo = false
                        }
                    }
                }
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
                .foregroundColor(isGranted ? .green : .blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isGranted ? .green : .gray)
        }
        .padding(.vertical, 8)
    }
}

// 預覽
struct PermissionsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsInfoView(showPermissionsInfo: .constant(true))
    }
}
