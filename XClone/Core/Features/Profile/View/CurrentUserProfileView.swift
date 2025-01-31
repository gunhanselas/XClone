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
    
    @State private var selectedTab = 0
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                if let user = userManager.currentUser {
                    ProfileHeaderView(user: user)
                    
                    VStack(spacing: 0) {
                        ProfileContentFilterView(selectedTab: $selectedTab)
                        
                        TabView(selection: $selectedTab) {
                            ForEach(ProfileContentFilterModel.allCases) { filter in
                                LazyVStack {
                                    ForEach(viewModel.posts(for: filter, uid: user.id)) { post in
    //                                    PostCell(post: post)
                                        Text(post.caption)
                                    }
                                }
                            }
                        }
                        .containerRelativeFrame(.vertical, { height, _ in
                            height / 1.75
                        })
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .padding(.vertical)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var userManager = UserManager(service: MockUserService())
    
    CurrentUserProfileView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService(),
                appleAuthService: AppleAuthService()
            )
        )
        .environment(userManager)
        .task { await userManager.fetchCurrentUser() }
}
