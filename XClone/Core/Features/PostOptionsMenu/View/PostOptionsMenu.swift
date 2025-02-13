//
//  PostCellOptionsMenu.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct PostOptionsMenu: View {
    @Environment(BlockingManager.self) private var blockingManager
    
    @State private var isShowingBlockAlert = false
    @State private var isShowingReportView = false
    
    @State private var viewModel = PostOptionsMenuViewModel()
    
    let post: Post
    
    var body: some View {
        Menu {
            if let author = post.author {
                if author.userRelationState == .isCurrentUser {
                    Button("Delete Post", role: .destructive) {
                        Task { await viewModel.deletePost(post) }
                    }
                } else {
                    Button("Report Post", action: {})

                    Menu("@\(author.username)") {
                        Button("Unfollow", action: {})
                        Button("Block", action: { isShowingBlockAlert.toggle() })
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.gray)
        }
        .alert("Block @\(post.author?.username ?? "")", isPresented: $isShowingBlockAlert, actions: {
            Button("Block", role: .destructive) {
                Task { await viewModel.blockUser(post.authorID) }
            }
            
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("They will be able to see your public posts, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.")
        })
        .sheet(isPresented: $isShowingReportView) {
            ReportContentView()
        }
    }
}

#Preview {
    PostOptionsMenu(post: MockData.post)
}
