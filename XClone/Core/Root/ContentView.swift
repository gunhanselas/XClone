//
//  ContentView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/23/25.
//

import GoogleSignIn
import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .notDetermined:
                ProgressView()
            case .unauthenticated:
                AuthenticationRootView()
            case .authenticated:
                MainTabView()
            }
        }
        .onAppear { authManager.configureAuthState() }
        .onChange(of: authManager.authState) { _, newValue in
            guard newValue == .authenticated else { return }
            Task { await userManager.fetchCurrentUser() }
        }
    }
}

#Preview {
    ContentView()
}
