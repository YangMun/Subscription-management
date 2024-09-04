import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoggedIn: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 30) {
                    logoAndTitle
                    loginForm
                    loginButton
                    forgotPasswordLink
                    divider
                    appleSignInButton
                    signUpLink
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "4A00E0"),
            colorScheme == .dark ? Color(hex: "2C2C2C") : Color(hex: "8E2DE2")
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    }
    
    var logoAndTitle: some View {
        VStack(spacing: 15) {
            Image(systemName: "square.stack.3d.up.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(colorScheme == .dark ? Color(hex: "8E2DE2") : .white)
            
            Text("SubScribe")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .white)
            
            Text("Manage all your subscriptions in one place")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }
    
    var loginForm: some View {
        VStack(spacing: 20) {
            CustomText(image: "envelope", placeholder: "Email", text: $email)
            CustomSecureField(image: "lock", placeholder: "Password", text: $password, isVisible: $isPasswordVisible)
        }
    }
    
    var loginButton: some View {
        Button(action: {
            // Login action
        }) {
            Text("Log In")
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A00E0"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? Color(hex: "8E2DE2") : .white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    var forgotPasswordLink: some View {
        Button("Forgot Password?") {
            // Forgot password action
        }
        .font(.footnote)
        .foregroundColor(colorScheme == .dark ? .gray : .white)
    }
    
    var divider: some View {
        HStack {
            VStack { Divider().background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.5)) }
            Text("OR").foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8)).font(.footnote)
            VStack { Divider().background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.5)) }
        }
    }
    
    var appleSignInButton: some View {
        AppleSignInButton()
    }
    
    var socialLoginButtons: some View {
        VStack(spacing: 20) {
            AppleSignInButton()
            SocialLoginButton(image: "g.circle.fill", color: colorScheme == .dark ? .white : .white) {
                // Google sign in action
            }
        }
    }
    
    var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            Button("Sign Up") {
                // Sign up action
            }
            .fontWeight(.semibold)
            .foregroundColor(colorScheme == .dark ? Color(hex: "8E2DE2") : .white)
        }
        .font(.footnote)
    }
    
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            print("Apple sign in successful")
            // Here you would typically send the authorization to your backend
            // For this example, we'll just set isLoggedIn to true
            self.isLoggedIn = true
        case .failure(let error):
            print("Apple sign in failed: \(error.localizedDescription)")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.light)
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
