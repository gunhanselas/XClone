//
//  PostDetailView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

struct PostDetailView: View {
    @Environment(FeedViewModel.self) private var viewModel
    
    @State private var showReplySortMenu = false
    @State private var selectedReplySortOption: ReplySortModel = .mostRecent
    
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    AvatarView(user: post.author, size: .medium)
                    
                    VStack(alignment: .leading) {
                        Text(post.author?.fullname ?? "")
                            .fontWeight(.semibold)
                        
                        Text("@\(post.author?.username ?? "")")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                
                Text(post.caption)
                    .font(.system(size: 22))
                
                Text(post.timestamp.detailedTimestampString())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                PostEngagementView(post: post)
                    .environment(viewModel)
                
                Button { showReplySortMenu.toggle() } label: {
                    HStack(spacing: 2) {
                        Text(selectedReplySortOption.description)
                        Image(systemName: "chevron.down")
                    }
                    .foregroundStyle(Color(.darkGray))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            Divider()
            
            LazyVStack {
                
            }
        }
        .sheet(isPresented: $showReplySortMenu) {
            ReplySortSelectionView(selectedReplySortOption: $selectedReplySortOption)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationDetents([.height(180)])
        }
        .padding()
    }
}

#Preview {
    PostDetailView(post: MockData.post)
        .environment(FeedViewModel(service: MockFeedService()))
}
