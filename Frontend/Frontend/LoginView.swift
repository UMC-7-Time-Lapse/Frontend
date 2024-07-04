import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser

// 로그인 화면

struct LoginView: View {
    @State private var userName: String = ""
    @State private var userMail: String = ""
    @State private var profileImage: URL?
    @State private var loginStatus: String = ""

    var body: some View {
        ZStack {
            
            VStack(spacing: 30) {
                VStack {
                    Text("5초만에")
                    Text("타임캡슐을 만들어 봐요")
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#392020"))
                .padding(.bottom, 30)
                
                Button(action: kakaoLogin) {
                    HStack {
                        Image("kakao_login_large_wide")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .background(Color(hex: "#FEE500"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#392020"), lineWidth: 2)
                    )
                }
                
                if !loginStatus.isEmpty {
                    Text(loginStatus)
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Button(action: kakaoLogout) {
                    Text("로그아웃")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .background(Color.red)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#392020"), lineWidth: 2)
                        )
                }
                
                if !userName.isEmpty {
                    Text("Name: \(userName)")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                if !userMail.isEmpty {
                    Text("Email: \(userMail)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                if let profileImage = profileImage {
                    AsyncImage(url: profileImage) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .padding()
        }
    }
    
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else if let oauthToken = oauthToken {
                    print(oauthToken)
                    loginStatus = "로그인 성공"
                    fetchUserInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else if let oauthToken = oauthToken {
                    print(oauthToken)
                    loginStatus = "로그인 성공"
                    fetchUserInfo()
                }
            }
        }
    }
    
    func fetchUserInfo() {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print(error)
            } else {
                if let profile = user?.kakaoAccount?.profile {
                    userName = profile.nickname ?? ""
                    profileImage = profile.profileImageUrl
                }
                userMail = user?.kakaoAccount?.email ?? ""
            }
        }
    }
    
    func kakaoLogout() {
        UserApi.shared.logout { (error) in
            if let error = error {
                print(error)
            } else {
                print("로그아웃 성공")
                loginStatus = "로그아웃 성공"
                userName = ""
                userMail = ""
                profileImage = nil
            }
        }
    }
}

#Preview {
    LoginView()
}
