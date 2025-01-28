//
//  LoginView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import GoogleSignIn
import SwiftUI

struct AuthenticationRootView: View {
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("See what's happening in the world right now.")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            VStack(spacing: 12) {
    
                XButton("Continue with Google", imageResource: .googleIcon) {
                    signInWithGoogle()
                }
                .buttonStyle(.standard)
                
                XButton("Continue with Apple", imageResource: .appleIcon) {
                    
                }
                .buttonStyle(.standard)
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.subheadline)
                    
                    Rectangle()
                        .frame(height: 1)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                
                XButton("Create Account") {
                    authManager.authState = .authenticated
                }
                .buttonStyle(.standard)
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Button { } label: {
                        Text("Have an account already? ")
                            .foregroundStyle(.gray)
                        +
                        
                        Text("Log in")
                            .foregroundStyle(.primary)
                    }
                    .font(.caption)
                }
                .padding(.vertical)
                .padding(.horizontal, 12)
            }
        }
    }
}

private extension AuthenticationRootView {
    func signInWithGoogle() {
        Task { await authManager.signInWithGoogle() }
    }
}

#Preview {
    AuthenticationRootView()
}
