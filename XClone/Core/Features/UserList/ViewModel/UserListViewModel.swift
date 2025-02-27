//
//  UserListViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

@Observable
class UserListViewModel {
    var users = [User]()
    var loadingState: ContentLoadingState = .loading
    
    private let service: UserListServiceProtocol
    
    init(service: UserListServiceProtocol = UserListService(userService: UserService())) {
        self.service = service
    }
    
    func updateUsersAfterUnblocking(_ user: User) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        users.remove(at: index)
        
        if users.isEmpty {
            loadingState = .empty
        }
    }
    
    func fetchUsers(forConfig config: UserListConfiguration, with blockingManager: BlockingManager) async {
        do {
            var data = try await service.fetchUsers(forConfig: config)
            
            if config != .blockedAccounts {
                data = blockingManager.filterBlockedUsers(data)
            }
            
            users.append(contentsOf: data)
            
            self.loadingState = users.isEmpty ? .empty : .complete
        } catch {
            self.loadingState = .error(error)
            print("DEBUG: Failed to fetch users with error: \(error)")
        }
    }
    
    func refreshUsers(forConfig config: UserListConfiguration, with blockingManager: BlockingManager) async {
        do {
            let data = try await service.refreshUsers(forConfig: config)
            self.users = blockingManager.filterBlockedUsers(data)
        } catch {
            self.loadingState = .error(error)
            print("DEBUG: Failed to refresh users with error: \(error)")
        }
    }
}
