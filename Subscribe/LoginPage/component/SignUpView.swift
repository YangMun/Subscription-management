import SwiftUI
import CoreData

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showLoginView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 30) {
                    logoAndTitle
                    signUpForm
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    signUpButton
                    loginLink
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
    }
    
    var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "4A00E0"),
            colorScheme == .dark ? Color(hex: "2C2C2C") : Color(hex: "8E2DE2")
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                .foregroundColor(.white)
            
            Text("Create your account")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
        }
        .padding(.bottom, 20)
    }
    
    var signUpForm: some View {
        VStack(spacing: 20) {
            CustomText(image: "person", placeholder: "Full Name", text: $fullName)
            CustomText(image: "envelope", placeholder: "Email", text: $email)
            CustomSecureField(image: "lock", placeholder: "Password", text: $password, isVisible: $isPasswordVisible)
            CustomSecureField(image: "lock", placeholder: "Confirm Password", text: $confirmPassword, isVisible: $isConfirmPasswordVisible)
        }
    }
    
    var signUpButton: some View {
        Button(action: {
            validateAndSignUp()
        }) {
            Text("Sign Up")
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A00E0"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? Color(hex: "8E2DE2") : .white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    
    
    var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            Button("Log In") {
                isPresented = false
            }
            .fontWeight(.semibold)
            .foregroundColor(colorScheme == .dark ? Color(hex: "8E2DE2") : .white)
        }
        .font(.footnote)
        .padding(.top, 20)
    }
    
    func validateAndSignUp() {
        // Reset error state
        errorMessage = ""
        showError = false
        
        // CoreData에서 기존 사용자 확인
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ OR email == %@", fullName, email)
        
        // 1. 모든 필드가 채워져 있는지 확인
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "모든 필드를 입력해주세요."
            showError = true
            return
        }
        
        // 2. 아이디(이메일)가 숫자, 특수문자로만 이루어지지 않았는지 확인
        let emailPattern = "^(?=.*[a-zA-Z])[a-zA-Z0-9@.]+$"
        guard fullName.range(of: emailPattern, options: .regularExpression) != nil else {
            errorMessage = "이메일은 숫자와 특수문자로만 이루어질 수 없습니다."
            showError = true
            return
        }
        
        // 3. 이메일 양식 확인
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            errorMessage = "올바른 이메일 형식이 아닙니다."
            showError = true
            return
        }
        
        // 4. 비밀번호와 비밀번호 확인이 일치하는지 확인
        guard password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            showError = true
            return
        }
        
        do {
            let existingUsers = try viewContext.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                // 이미 존재하는 사용자가 있는 경우
                if existingUsers.first?.id == fullName {
                    errorMessage = "이미 사용 중인 ID입니다."
                } else {
                    errorMessage = "이미 사용 중인 이메일 주소입니다."
                }
                showError = true
                return
            }
            
            // 새 사용자 생성 및 저장
            let newUser = Login(context: viewContext)
            newUser.id = fullName
            newUser.email = email
            newUser.password = password
            
            try viewContext.save()
            print("회원가입 성공! CoreData에 저장되었습니다.")
            // 회원가입 성공 후의 추가 로직을 구현하세요 (예: 로그인 화면으로 이동)
            isPresented = false
        } catch {
            // 에러 처리
            let nsError = error as NSError
            errorMessage = "회원가입 중 오류가 발생했습니다: \(nsError.localizedDescription)"
            showError = true
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpView(isPresented: .constant(true))
                .preferredColorScheme(.light)
            SignUpView(isPresented: .constant(true))
                .preferredColorScheme(.dark)
        }
    }
}
