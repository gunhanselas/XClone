//
//  PasswordView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct CreatePasswordView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AuthenticationRouter.self) private var authRouter
    
    @State private var isLoading = false
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("You'll need a password")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Make sure it's \(Constants.minimumPasswordCount) characters or more.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                FormInputField(
                    "Password",
                    isSecureField: true,
                    text: $password
                )
                    .textContentType(.password)
            }
                        
            VStack(spacing: 20) {
                Text("By signing up, you agree to the Terms of Service and Privacy Policy.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                XButton("Sign up") {
                    onSignUp()
                }
                .buttonStyle(.standard, isLoading: $isLoading)
                .disabled(!password.isValidPassword())
                .opacity(password.isValidPassword() ? 1.0 : 0.4)
            }
            
            Spacer()
        }
        .padding()
    }
}

private extension CreatePasswordView {
    func onSignUp() {
        Task {
            isLoading = true
            await authManager.signUp(withEmail: "", password: "", username: "")
            isLoading = false
            authRouter.pushNextAccountCreationStep()
        }
    }
}

#Preview {
    CreatePasswordView()
}
