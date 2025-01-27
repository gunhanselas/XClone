//
//  PostEngagementView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostEngagementView: View {
    @Environment(FeedViewModel.self) private var viewModel
    @State private var showRepliesView = false
    
    let post: Post
    
    var body: some View {
        HStack {
            Button { showRepliesView.toggle() } label: {
                PostEngagementStatView(imageName: "bubble", count: post.engagement.commentsCount)
            }
            
            Spacer()
            
            Button {} label: {
                PostEngagementStatView(imageName: "repeat", count: post.engagement.repostsCount)
            }
            
            Spacer()
            
            Button {} label: {
                PostEngagementStatView(imageName: "heart", count: post.engagement.likesCount)
            }
            
            Spacer()
            
            PostEngagementStatView(imageName: "chart.bar", count: post.engagement.impressionsCount)
        }
        .fullScreenCover(isPresented: $showRepliesView) {
            PostRepliesView(post: post)
        }
        .padding(.vertical, 6)
        .foregroundStyle(Color(.darkGray))
    }
}

#Preview {
    PostEngagementView(post: MockData.post)
        .environment(FeedViewModel(service: MockFeedService()))
}
