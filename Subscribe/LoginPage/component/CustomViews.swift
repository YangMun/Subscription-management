import SwiftUI

struct CustomText: View {
    let image: String
    let placeholder: String
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            TextField(placeholder, text: $text)
                .foregroundColor(colorScheme == .dark ? .white : .white)
        }
        .padding()
        .background(colorScheme == .dark ? Color(hex: "2C2C2C") : Color.white.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    let image: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            if isVisible {
                TextField(placeholder, text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
            }
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(colorScheme == .dark ? .gray : .white.opacity(0.8))
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(hex: "2C2C2C") : Color.white.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
