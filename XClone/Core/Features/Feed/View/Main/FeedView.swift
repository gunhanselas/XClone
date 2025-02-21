//
//  FeedView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct FeedView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(SnackbarNotificationManager.self) private var snackbarManager
    
    @State private var viewModel = FeedViewModel()
    @State private var isShowingPostCreationView = false
    @State private var showPostSentSnackbar = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    switch viewModel.loadingState {
                    case .loading:
                        ProgressView()
                            .containerRelativeFrame(.vertical)
                    case .empty:
                        Text("Feed Empty State")
                            .frame(maxWidth: .infinity)
                    case .error:
                        Text("An error occurred")
                    case .complete:
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                NavigationLink(value: FeedRoutes.postDetail(post)) {
                                    FeedPostCell(post: post, viewModel: viewModel)
                                }
                            }
                        }
                    }
                }
                
                if shouldShowCreatePostButton {
                    Button { isShowingPostCreationView.toggle() } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background {
                                Circle()
                                    .fill(.primaryBlue)
                                    .frame(width: 54, height: 54)
                                    .shadow(color: .primary.opacity(0.25), radius: 6)
                            }
                            .padding()
                    }
                }
            }
            .refreshable { await viewModel.refreshFeed() }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isShowingPostCreationView) {
                PostCreationView()
                    .environment(userManager)
                    .environment(snackbarManager)
            }
            .navigationDestination(for: FeedRoutes.self) { route in
                switch route {
                case .profile(let user):
                    UserProfileView(user: user)
                case .postDetail(let post):
                    PostDetailView(post: post, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AvatarView(user: userManager.currentUser, size: .xSmall)
                }
                
                ToolbarItem(placement: .principal) {
                    XLogoImageView(size: .small)
                }
            }
        }
        .snackbar(message: "Your post was sent", show: $showPostSentSnackbar)
        
    }
}

private extension FeedView {
    var shouldShowCreatePostButton: Bool {
        return viewModel.loadingState == .complete ||
        viewModel.loadingState == .empty
    }
}

#Preview {
    FeedView()
}
