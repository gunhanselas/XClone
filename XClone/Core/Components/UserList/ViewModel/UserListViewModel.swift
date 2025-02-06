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
    
    func fetchUsers(forConfig config: UserListConfiguration) async {
        do {
            let data = try await service.fetchUsers(forConfig: config)
            users.append(contentsOf: data)
            self.loadingState = users.isEmpty ? .empty : .complete
        } catch {
            self.loadingState = .error(error)
            print("DEBUG: Failed to fetch users with error: \(error)")
        }
    }
}
