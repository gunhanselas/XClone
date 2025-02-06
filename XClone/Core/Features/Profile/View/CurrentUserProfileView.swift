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
    
    @State private var selectedFilter: ProfileContentFilterModel = .posts
    @State private var viewModel = ProfileViewModel(
        profileService: MockProfileService(),
        likeService: MockLikePostService()
    )
    
    var body: some View {
        ScrollView {
            VStack {
                if let user = userManager.currentUser {
                    ProfileHeaderView(user: user)
                    
                    VStack(spacing: 4) {
                        ProfileContentFilterView(selectedFilter: $selectedFilter)
                        
                        switch viewModel.loadingState {
                        case .loading:
                            ProgressView()
                                .padding()
                        case .empty:
                            Text("Configure empty state..")
                        case .error(let error):
                            Text("An error ocurred: \(error.localizedDescription)")
                        case .complete:
                            LazyVStack {
                                ForEach(viewModel.currentDataSource) { post in
                                    PostCell(post: post, viewModel: viewModel)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .task {
            guard let currentUser = userManager.currentUser else { return }
            await viewModel.fetchContent(for: currentUser.id)
        }
        .onChange(of: selectedFilter) { _, newValue in
            viewModel.setCurrentDataSource(for: newValue)
        }
        .ignoresSafeArea(edges: .top)
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
