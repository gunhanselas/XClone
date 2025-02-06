//
//  PostRepliesView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostRepliesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showUploadFailureAlert = false
    @State private var isUploadingReply = false
    @State private var replyText: String = ""
    @State private var viewModel: PostReplyViewModel
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
        
        _viewModel = State(
            initialValue: PostReplyViewModel(
                service: PostReplyService(postId: post.id)
            )
        )
    }
    
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
            .alert("Error", isPresented: $showUploadFailureAlert, actions: {
                Button("Ok", role: .cancel) {}
            }, message: {
                Text("There was an error sending your reply. Please try again later.")
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    XButton("Post", action: uploadReply)
                        .buttonStyle(
                            .standard(size: .compact, variant: .primary),
                            isLoading: $isUploadingReply
                        )
                        .disabled(replyText.isEmpty)
                        .opacity(replyText.isEmpty ? 0.5 : 1.0)
                }
            }
        }
    }
}

private extension PostRepliesView {
    func uploadReply() {
        Task {
            isUploadingReply = true
            defer { isUploadingReply = false }
            
            do {
                try await viewModel.uploadReply(caption: replyText)
                dismiss()
            } catch {
                print("DEBUG: Error uploading reply \(error)")
                showUploadFailureAlert.toggle()
            }
        }
    }
}

#Preview {
    PostRepliesView(post: MockData.post)
}
