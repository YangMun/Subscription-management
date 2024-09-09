import SwiftUI
import AuthenticationServices
import CoreData

struct SlideTransition: ViewModifier {
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
    }
}

struct LoginView: View {
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var showMainPage = false
    @State private var showSignUp = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var slideOffset: CGFloat = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case id
        case password
    }
    
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
                    socialLoginButtons
                    signUpLink
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
            }
            .modifier(SlideTransition(offset: showMainPage ? -slideOffset : 0))
            .animation(.easeInOut(duration: 0.3), value: showMainPage)
            
            if showMainPage {
                MainPage()
                    .modifier(SlideTransition(offset: showMainPage ? 0 : slideOffset))
                    .animation(.easeInOut(duration: 0.3), value: showMainPage)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(isPresented: $showSignUp)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("로그인 오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
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
            CustomText(image: "person", placeholder: "id", text: $id)
                .focused($focusedField, equals: .id)
            CustomSecureField(image: "lock", placeholder: "Password", text: $password, isVisible: $isPasswordVisible)
                .focused($focusedField, equals: .password)
        }
    }
    
    var loginButton: some View {
        Button(action: {
            dismissKeyboard()
            login()
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
    
    var socialLoginButtons: some View {
        VStack(spacing: 20) {
            AppleSignInButton()
//            SocialLoginButton(image: "g.circle.fill", color: colorScheme == .dark ? .white : .white) {
//                // Google sign in action
//            }
        }
    }
    
    var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            Button("Sign Up") {
                showSignUp = true
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
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func login() {
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND password == %@", id, password)
        
        do {
            let matchingUsers = try viewContext.fetch(fetchRequest)
            if !matchingUsers.isEmpty {
                print("로그인 성공!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        showMainPage = true
                    }
                }
            } else {
                alertMessage = "아이디 또는 비밀번호가 일치하지 않습니다."
                showingAlert = true
            }
        } catch {
            alertMessage = "로그인 중 오류가 발생했습니다. 다시 시도해 주세요."
            showingAlert = true
            print("로그인 중 오류 발생: \(error.localizedDescription)")
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
