import SwiftUI
import AuthenticationServices

// 여기엔 구글 로그인 구현하기
struct SocialLoginButton: View {
    let image: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .foregroundColor(colorScheme == .dark ? .black : Color(hex: "4A00E0"))
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}

// 애플 로그인
struct AppleSignInButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingMainPage = false
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Apple Sign In successful!")
                    // 여기서 사용자 정보를 처리하고 저장할 수 있습니다.
                    // 예: 사용자 ID, 이메일 등
                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        let userIdentifier = appleIDCredential.user
                        let fullName = appleIDCredential.fullName
                        let email = appleIDCredential.email
                        
                        // 여기서 사용자 정보를 저장하거나 서버로 전송할 수 있습니다.
                        
                        // 로그인 성공 후 MainPage로 이동
                        isShowingMainPage = true
                    }
                case .failure(let error):
                    print("Apple Sign In failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .fullScreenCover(isPresented: $isShowingMainPage) {
            MainPage()
        }
    }
}
