//
//  FeedView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct FeedView: View {
    @Environment(UserManager.self) private var userManager
    
    @State private var viewModel = FeedViewModel(service: MockFeedService())
    @State private var isShowingPostCreationView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
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
                
                if case .complete = viewModel.loadingState {
                    Button { isShowingPostCreationView.toggle() } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background {
                                Circle()
                                    .fill(.primaryBlue)
                                    .frame(width: 54, height: 54)
                                    .shadow(color: .primary.opacity(0.25), radius: 6)
                            }
                            .padding()
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingPostCreationView) {
                PostCreationView()
                    .environment(userManager)
            }
            .padding(.vertical)
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
