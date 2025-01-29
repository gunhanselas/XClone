//
//  PostRepliesView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostRepliesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var replyText: String = ""
    
    let post: Post
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                    .padding(.top, 6)
                
                HStack(alignment: .top) {
                    AvatarView(user: post.author, size: .xSmall)
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            Text(post.author?.username ?? "")
                                .foregroundStyle(.primaryText)
                                .fontWeight(.semibold)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                            
                            Text(post.timestamp.timestampString())
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        
                        Text(post.caption)
                            .foregroundStyle(.primaryText)
                            .multilineTextAlignment(.leading)
                    }
                }
                .font(.subheadline)
                .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Replying to @\(post.author?.username ?? "")")
                        .padding(.leading, AvatarSize.xSmall.dimension + 8)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    HStack(alignment: .top) {
                        AvatarView(user: post.author, size: .xSmall)
                        
                        TextField("Post your reply...", text: $replyText, axis: .vertical)
                            .offset(y: AvatarSize.xSmall.dimension / 4)
                            .multilineTextAlignment(.leading)
                    }
                }
                .font(.subheadline)
                .padding()
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Text("Post")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 36)
                            .background(.blue)
                            .clipShape(.capsule)
                    }
                    .disabled(replyText.isEmpty)
                    .opacity(replyText.isEmpty ? 0.5 : 1.0)
                }
            }
        }
    }
}

#Preview {
    PostRepliesView(post: MockData.post)
}
