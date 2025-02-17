//
//  PostEngagementView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostEngagementView<ViewModel: FeedViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var showRepliesView = false
    
    private let post: Post
    
    init(post: Post, viewModel: ViewModel) {
        self.viewModel = viewModel
        self.post = post
    }
    
    var body: some View {
        HStack {
            Button { showRepliesView.toggle() } label: {
                PostEngagementStatView(imageName: "bubble", count: post.engagement.replyCount)
            }
            
            Spacer()
            
            Button {} label: {
                PostEngagementStatView(imageName: "repeat", count: post.engagement.repostsCount)
            }
            
            Spacer()
            
            Button { handleLikeTapped() } label: {
                PostEngagementStatView(
                    imageName: isPostLiked ? "heart.fill" : "heart",
                    imageForegroundColor: isPostLiked ? Color(.red) : .secondary,
                    count: likesCount
                )
            }
            
            Spacer()
            
            PostEngagementStatView(imageName: "chart.bar", count: post.engagement.impressionsCount)
        }
        .task { await viewModel.didLike(post) }
        .fullScreenCover(isPresented: $showRepliesView) {
            PostRepliesView(post: post)
        }
        .padding(.vertical, 6)
        .foregroundStyle(Color(.darkGray))
    }
}

private extension PostEngagementView {
    func handleLikeTapped() {
        guard let postIndex else { return }
        
        Task {
            if viewModel.posts[postIndex].didLike {
                await viewModel.unlikePost(post)
            } else {
                await viewModel.likePost(post)
            }
        }
    }
    
    var isPostLiked: Bool {
        guard let postIndex else { return false }
        return viewModel.posts[postIndex].didLike
    }
    
    var likesCount: Int {
        guard let postIndex else { return 0 }
        return viewModel.posts[postIndex].engagement.likesCount
    }
    
    var postIndex: Int? {
        return viewModel.posts.firstIndex(where: { $0.id == post.id })
    }
}

#Preview {
    PostEngagementView<FeedViewModel>(post: MockData.post, viewModel: FeedViewModel(
        feedService: MockFeedService(),
        likeService: MockLikePostService()
    ))
}
