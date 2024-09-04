import SwiftUI

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
    
    var body: some View {
        Button(action: {
            // 여기에 로그인 기능 대신 임시 액션을 넣을 수 있습니다.
            
        }) {
            HStack {
                Image(systemName: "apple.logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text("Continue with Apple")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
            )
            .cornerRadius(5)
        }
        .frame(height: 50)
    }
}
