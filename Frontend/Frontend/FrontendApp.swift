import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct FrontendApp: App {
    
    // 카카로 로그인 토큰
    init() {
        KakaoSDK.initSDK(appKey: "45af461a16f86a3fa26a654fc50e4c78")
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            
            // 카카오 로그인 구현시 필요
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
