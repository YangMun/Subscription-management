import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 30) {
                    logoAndTitle
                    signUpForm
                    signUpButton
                    loginLink
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
            // Sign up action
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
