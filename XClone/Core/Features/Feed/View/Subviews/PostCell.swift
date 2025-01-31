//
//  FeedCell.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

struct PostCell: View {    
    let post: Post
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(user: post.author, size: .small)
                
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
                        
                        Button { } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Text(post.caption)
                        .multilineTextAlignment(.leading)
                    
                    if let imageUrl = post.imageURL {
                        KFImage(URL(string: imageUrl))
                            .placeholder { ProgressView() }
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 200)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 8)
            
            PostEngagementView(post: post)
                .padding(.horizontal)
            
            Divider()
        }
        .foregroundStyle(Color(.primaryText))
    }
}

#Preview {
    PostCell(post: MockData.post)
}
