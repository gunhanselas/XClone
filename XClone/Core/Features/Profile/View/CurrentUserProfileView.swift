//
//  CurrentUserProfileView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/27/25.
//

import SwiftUI

struct CurrentUserProfileView: View {
    let currentUser: User
    
    var body: some View {
        NavigationStack {
            UserProfileView(user: currentUser)
        }
    }
}

#Preview {
    CurrentUserProfileView(currentUser: MockData.currentUser)
}
