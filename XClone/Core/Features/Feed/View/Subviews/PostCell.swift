//
//  FeedCell.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

struct PostCell<ViewModel: FeedViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel
    private let post: Post
    
    init(post: Post, viewModel: ViewModel) {
        self.post = post
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                if let user = post.author {
                    NavigationLink(value: FeedRoutes.profile(user)) {
                        AvatarView(user: post.author, size: .small)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 2) {
                        Text(post.author?.username ?? "")
                            .fontWeight(.semibold)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(post.timestamp.timestampString())
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        PostCellOptionsMenu()
                    }
                    
                    Text(post.caption)
                        .multilineTextAlignment(.leading)
                    
                    if let imageUrl = post.imageURL {
                        KFImage(URL(string: imageUrl))
                            .placeholder { ProgressView() }
                            .resizable()
                            .scaledToFill()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(.rect(cornerRadius: 10))
                            .contentShape(.rect)
                    }
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 8)
            
            PostEngagementView(post: post, viewModel: viewModel)
                .padding(.horizontal)
            
            Divider()
        }
        .foregroundStyle(Color(.primaryText))
    }
}

#Preview {
    PostCell(
        post: MockData.post,
        viewModel: FeedViewModel(
            feedService: MockFeedService(),
            likeService: MockLikePostService()
        )
    )
}
