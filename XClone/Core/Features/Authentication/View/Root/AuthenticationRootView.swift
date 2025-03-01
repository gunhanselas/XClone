//
//  LoginView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import AuthenticationServices
import GoogleSignIn
import SwiftUI

struct AuthenticationRootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    @State private var router = AuthenticationRouter()
    @StateObject private var dataStore = AuthDataStore()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                XLogoImageView()
                    .padding()
                
                Spacer()
                
                Text("See what's happening in the world right now.")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    XButton("Continue with Google", imageResource: .googleIcon) {
                        signInWithGoogle()
                    }
                    .buttonStyle(.standard(rank: .secondary))

                    XButton("Continue with Apple", systemImage: "apple.logo") {
                        signInwithApple()
                    }
                    .buttonStyle(.standard(rank: .secondary))
                    
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
                        router.startAccountCreationFlow()
                    }
                    .buttonStyle(.standard(rank: .secondary))

                    VStack(alignment: .leading, spacing: 24) {
                        Text("By signing up, you agree to our Terms of Service.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        Button { router.showLogin() } label: {
                            Text("Have an account already? ")
                                .foregroundStyle(.gray)
                            +
                            
                            Text("Log in")
                                .foregroundStyle(.primary)
                        }
                        .font(.caption)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 8)
                }
            }
            .onChange(of: authManager.googleAuthUser) { _, newValue in
                guard let newValue, newValue.isNewUser else { return }
                saveUserDataAndShowCreateUsernameView(newValue)
            }
            .onChange(of: authManager.appleAuthUser) { _, newValue in
                guard let newValue, newValue.isNewUser else { return }
                saveUserDataAndShowCreateUsernameView(newValue)
            }
            .navigationDestination(for: AuthenticationRoutes.self) { route in
                Group {
                    switch route {
                    case .login(let loginRoute):
                        loginRoute.destination
                    case .accountCreation(let accountCreationRoute):
                        accountCreationRoute.destination
                    case .oAuth(let oAuthRoute):
                        oAuthRoute.destination
                    }
                }
                .environment(router)
                .environmentObject(dataStore)
            }
        }
    }
}

private extension AuthenticationRootView {
    func signInWithGoogle() {
        Task { await authManager.signInWithGoogle() }
    }
    
    func signInwithApple() {
        authManager.requestAppleAuthorization()
    }
    
    func saveUserDataAndShowCreateUsernameView(_ user: any BaseUser) {
        Task {
            await userManager.saveUserDataAfterAuthentication(user)
            router.showUsernameViewAfterOAuth()
        }
    }
}

#Preview {
    AuthenticationRootView()
}
