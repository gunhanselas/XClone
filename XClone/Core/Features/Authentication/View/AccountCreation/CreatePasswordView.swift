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
    @Environment(UserManager.self) private var userManager
    @EnvironmentObject private var store: AuthDataStore

    @State private var isLoading = false
    @State private var error: Error?
    
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
                    text: $store.password
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
            defer { isLoading = false }
            
            do {
                let user = try await authManager.signUp(
                    withEmail: store.email,
                    password: store.password,
                    username: store.username,
                    fullname: store.name
                )
                
                await userManager.saveUserDataAfterAuthentication(user)
                
                authRouter.pushNextAccountCreationStep()
            } catch {
                self.error = error
            }
        }
    }
    
    var password: String {
        return store.password
    }
}

#Preview {
    CreatePasswordView()
}
