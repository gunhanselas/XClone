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
                if config == .blockedAccounts {
                    ContentUnavailableView(
                        "No blocked accounts.",
                        systemImage: "person.slash",
                        description: Text("Accounts you've blocked will appear here.")
                    )
                }
            case .error(let error):
                Text(error.localizedDescription)
            case .loading:
                ProgressView()
                    .containerRelativeFrame(.vertical)
            case .complete:
                LazyVStack(spacing: 12) {
                    ForEach(filteredUsers) { user in
                        Group {
                            switch config {
                            case .blockedAccounts:
                                UserCell(user: user, accessoryButtonTitle: "Unblock") {
                                    unblockUser(user)
                                }
                            case .explore, .likes, .following, .followers:
                                NavigationLink(value: user) {
                                    UserCell(user: user)
                                        .id(user.id)
                                }
                            case .newMessage:
                                UserCell(user: user)
                                    .onTapGesture { onCellTap(user) }
                            }
                        }
                        .id(user.id)
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
        return config != .newMessage && config != .blockedAccounts
    }
    
    func onCellTap(_ user: User) {
        guard !isNavigable else { return }
        selectedUser = user
        
        if config == .newMessage {
            dismiss()
        }
    }
    
    func unblockUser(_ user: User) {
        Task {
            await blockingManager.unblockUser(user)
            viewModel.updateUsersAfterUnblocking(user)
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
