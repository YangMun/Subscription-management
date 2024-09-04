import SwiftUI

struct SocialLoginButton: View {
    let image: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            // Social login action
        }) {
            Image(systemName: image)
                .foregroundColor(colorScheme == .dark ? .black : Color(hex: "4A00E0"))
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}
