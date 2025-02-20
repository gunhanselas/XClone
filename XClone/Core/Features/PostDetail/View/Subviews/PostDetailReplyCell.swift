//
//  PostDetailReplyCell.swift
//  XClone
//
//  Created by Stephan Dowless on 2/19/25.
//

import Kingfisher
import SwiftUI

struct PostDetailReplyCell: View {
    let post: Post
    
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
                        
                        PostOptionsMenu(post: post)
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
            
            Divider()
        }
        .foregroundStyle(Color(.primaryText))

    }
}

#Preview {
    PostDetailReplyCell(post: MockData.post)
}
