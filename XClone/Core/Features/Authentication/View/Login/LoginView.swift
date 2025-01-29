//
//  LoginView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @EnvironmentObject private var store: AuthDataStore
    
    @State private var isAuthenticating = false
    
    var body: some View {
        VStack {            
            XLogoImageView()
            
            VStack(spacing: 20) {
                FormInputField("Email", text: $store.email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                FormInputField("Password", isSecureField: true, text: $store.password)
            }
            .padding(.vertical, 24)
            
            Spacer()
            
            VStack(spacing: 20) {
                XButton("Login") {
                    login()
                }
                .buttonStyle(.standard, isLoading: $isAuthenticating)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                Button { } label: {
                    Text("Forgot password?")
                        .underline()
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primaryText)
                }
            }
        }
        .padding()
    }
}

private extension LoginView {
    func login() {
        Task {
            isAuthenticating = true
            await authManager.login(withEmail: store.email, password: store.password)
            isAuthenticating = false
        }
    }
    
    var formIsValid: Bool {
        return store.email.isValidEmail() && store.password.isValidPassword()
    }
}

#Preview {
    LoginView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService()
            )
        )
}
