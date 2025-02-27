//
//  CurrentUserProfileView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import SwiftUI

struct UserProfileView: View {    
    @State private var selectedFilter: ProfileContentFilterModel = .posts
    @State private var viewModel: ProfileViewModel
        
    init(user: User) {
        _viewModel = State(initialValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ProfileHeaderView(user: viewModel.user)
                    .environment(viewModel)
                
                VStack(spacing: 4) {
                    ProfileContentFilterView(selectedFilter: $selectedFilter)
                    
                    switch viewModel.loadingState {
                    case .loading:
                        ProgressView()
                            .padding()
                    case .empty:
                        Text("Configure empty state..")
                    case .error:
                        Text("An error ocurred.")
                    case .complete:
                        LazyVStack {
                            ForEach(viewModel.currentDataSource) { post in
                                NavigationLink(value: post) {
                                    FeedPostCell(post: post, viewModel: viewModel)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post, viewModel: viewModel)
        }
        .navigationBarBackButtonHidden()
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.fetchUserContent() }
        .task { await viewModel.fetchUserRelationState() }
        .onChange(of: selectedFilter) { _, newValue in
            viewModel.setCurrentDataSource(for: newValue)
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    UserProfileView(user: MockData.currentUser)
}
