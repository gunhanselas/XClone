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

    let post: Post
    
    var body: some View {
        Menu {
            Button("Report Post", action: {})
            
            if let author = post.author {
                Menu("@\(author.username)") {
                    Button("Unfollow", action: {})
                    Button("Block", action: { isShowingBlockAlert.toggle() })
                }
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.gray)
        }
        .alert("Block @\(post.author?.username ?? "")", isPresented: $isShowingBlockAlert, actions: {
            Button("Block", role: .destructive) {
                // block user here..
            }
            
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("They will be able to see your public posts, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.")
        })
    }
}

#Preview {
    PostOptionsMenu(post: MockData.post)
}
