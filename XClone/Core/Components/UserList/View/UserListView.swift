//
//  UserListView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import SwiftUI

struct UserListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BlockingManager.self) private var blockingManager
    
    @Binding private var selectedUser: User?
    
    @State private var searchText = ""
    @State private var viewModel = UserListViewModel()
    @State private var activeScrollId: String?
    @State private var paginating = false
    
    private let config: UserListConfiguration
    
    init(config: UserListConfiguration) {
        _selectedUser = .constant(nil)
        
        self.config = config
    }
    
    init(config: UserListConfiguration, selectedUser: Binding<User?>) {
        _selectedUser = selectedUser
        
        self.config = config
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.loadingState {
            case .empty:
                Text("User empty state..")
            case .error:
                Text("An error occurred.")
            case .loading:
                ProgressView()
                    .containerRelativeFrame(.vertical)
            case .complete:
                LazyVStack(spacing: 12) {
                    ForEach(filteredUsers) { user in
                        NavigationLink(value: user) {
                            UserCell(user: user)
                        }
                        .disabled(!isNavigable)
                        .id(user.id)
                        .simultaneousGesture(TapGesture().onEnded {
                            onCellTap(user)
                        })
                    }
                    
                    if paginating { ProgressView() }
                }
                .scrollTargetLayout()
                .padding(.top, 8)
                .searchable(text: $searchText, prompt: "Search...")
            }
        }
        .task { await viewModel.fetchUsers(forConfig: config, with: blockingManager) }
        .refreshable { await viewModel.refreshUsers(forConfig: config, with: blockingManager) }
        .overlay {
            if filteredUsers.isEmpty { ContentUnavailableView.search }
        }
        .scrollPosition(id: $activeScrollId, anchor: .bottom)
        .onChange(of: activeScrollId) { _, newValue in
            loadMoreUsersIfNecessary(newValue)
        }
        .navigationDestination(for: User.self) { user in
            UserProfileView(user: user)
        }
        .navigationTitle(config.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension UserListView {
    var isNavigable: Bool {
        return config != .newMessage
    }
    
    func onCellTap(_ user: User) {
        guard !isNavigable else { return }
        selectedUser = user
        
        if config == .newMessage {
            dismiss()
        }
    }
    
    var filteredUsers: [User] {
        let query = searchText.lowercased()
        
        if searchText.isEmpty {
            return viewModel.users
        } else {
            return viewModel.users.filter {
                $0.username.lowercased().contains(query)
            }
        }
    }
    
    func loadMoreUsersIfNecessary(_ activeScrollId: String?) {
        guard activeScrollId == viewModel.users.last?.id else { return }
        
        Task {
            paginating = true
            await viewModel.fetchUsers(forConfig: config, with: blockingManager)
            paginating = false
        }
    }
}

#Preview {
    UserListView(config: .explore)
}
