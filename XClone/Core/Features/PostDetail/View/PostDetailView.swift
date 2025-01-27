//
//  PostDetailView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

struct PostDetailView: View {
    @State private var viewModel = PostDetailViewModel(service: PostDetailService())
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
                    .font(.title3)
                
                Text(post.timestamp.detailedTimestampString())
                    .font(.subheadline)
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
            .padding([.horizontal, .top])

            Divider()
            
            LazyVStack {
                switch viewModel.loadingState {
                case .loading:
                    ProgressView()
                case .empty:
                    EmptyView()
                case .error(let error):
                    Text("An error ocurred: \(error.localizedDescription)")
                case .complete:
                    ForEach(viewModel.replies) { reply in
                        PostCell(post: reply)
                    }
                }
            }
            .padding()
        }
        .task(id: selectedReplySortOption) {
            await viewModel.fetchReplies(for: post, sortOption: selectedReplySortOption)
        }
        .sheet(isPresented: $showReplySortMenu) {
            ReplySortSelectionView(selectedReplySortOption: $selectedReplySortOption)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationDetents([.height(180)])
        }
    }
}

#Preview {
    PostDetailView(post: MockData.post)
        .environment(FeedViewModel(service: MockFeedService()))
}
