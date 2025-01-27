//
//  FeedView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel(service: MockFeedService())
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch viewModel.loadingState {
                case .loading:
                    ProgressView()
                        .containerRelativeFrame(.vertical)
                case .empty:
                    Text("Feed Empty State")
                case .error:
                    Text("An error occurred")
                case .complete:
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.posts) { post in
                            NavigationLink(value: post) {
                                PostCell(post: post)
                                    .environment(viewModel)
                            }
                        }
                    }
                }
            }
            .task { await viewModel.fetchPosts() }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
                    .environment(viewModel)
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
}
