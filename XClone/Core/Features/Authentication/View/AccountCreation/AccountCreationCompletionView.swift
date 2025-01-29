//
//  AccountCreationCompletionView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import SwiftUI

struct AccountCreationCompletionView: View {
    @Environment(AuthManager.self) private var authManager
    @EnvironmentObject private var store: AuthDataStore
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            XLogoImageView()
                .padding()
            
            Text("Welcome to X, \(store.username)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
                .multilineTextAlignment(.center)
            
            Text("Click below to complete registration and start using X")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            XButton("Complete Sign Up") {
                authManager.updateAuthState(.authenticated)
            }
            .buttonStyle(.standard)
            
            Spacer()
        }
    }
}

#Preview {
    AccountCreationCompletionView()
}
