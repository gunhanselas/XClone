//
//  PostCellOptionsMenu.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct PostOptionsMenu: View {
    @Environment(BlockingManager.self) private var blockingManager
    
    @State private var followButtonTitle = ""
    @State private var userRelationState: UserRelationState = .unknown
    @State private var isShowingBlockAlert = false
    @State private var isShowingReportView = false
    
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
                Task { await viewModel.blockUser(post.authorID) }
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
    
    func followAction() {
        Task {
            if userRelationState == .followed {
                await viewModel.unfollow(post.authorID)
            } else if userRelationState == .notFollowed {
                await viewModel.follow(post.authorID)
            }
        }
    }
}

#Preview {
    PostOptionsMenu(post: MockData.post)
}
