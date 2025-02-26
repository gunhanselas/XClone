//
//  PostCellOptionsMenu.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct PostOptionsMenu: View {
    @Environment(BlockingManager.self) private var blockingManager
    @Environment(SnackbarNotificationManager.self) private var snackbarManager
    
    @State private var followButtonTitle = ""
    @State private var userRelationState: UserRelationState = .unknown
    @State private var isShowingBlockAlert = false
    @State private var isShowingReportView = false
    @State private var didCompleteBlocking = false
    
    @State private var viewModel = PostOptionsMenuViewModel()
    
    let post: Post
    
    var body: some View {
        Menu {
            if userRelationState == .isCurrentUser {
                Button("Delete Post", role: .destructive) {
                    Task { await viewModel.deletePost(post) }
                }
            } else {
                if let author = post.author {
                    Button("Report Post", action: { isShowingReportView.toggle() })

                    Menu("@\(author.username)") {
                        Button(followButtonTitle) {
                            followAction()
                        }
                        
                        Button("Block") {
                            isShowingBlockAlert.toggle()
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.gray)
        }
        .task { await configureFollowState() }
        .alert("Block @\(post.author?.username ?? "")", isPresented: $isShowingBlockAlert, actions: {
            Button("Block", role: .destructive) {
                onBlock()
            }
            
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("They will be able to see your public posts, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.")
        })
        .sheet(isPresented: $isShowingReportView) {
            ReportContentView(contentType: .post(post: post))
        }
    }
}

private extension PostOptionsMenu {
    func configureFollowState() async {
        self.userRelationState = await viewModel.fetchUserRelationState(post.authorID)
        self.followButtonTitle = userRelationState == .followed ? "Unfollow" : "Follow"
    }
    
    func onBlock() {
        Task {
            await blockingManager.blockUser(post.authorID)
            
            if let user = post.author {
                snackbarManager.show(.blocked(user))
            }
        }
    }
    
    func followAction() {
        guard let author = post.author else { return }
        
        Task {
            if userRelationState == .followed {
                await viewModel.unfollow(post.authorID)
                snackbarManager.show(.unfollowed(author))
            } else if userRelationState == .notFollowed {
                await viewModel.follow(post.authorID)
                snackbarManager.show(.followed(author))
            }
        }
    }
}

#Preview {
    PostOptionsMenu(post: MockData.post)
}
