//
//  CurrentUserProfileView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import SwiftUI

struct CurrentUserProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        VStack {
            Button("Sign Out") {
                authManager.signOut()
            }
        }
    }
}

#Preview {
    CurrentUserProfileView()
}
