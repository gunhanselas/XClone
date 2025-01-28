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
        
    }
}

#Preview {
    ContentView()
}
