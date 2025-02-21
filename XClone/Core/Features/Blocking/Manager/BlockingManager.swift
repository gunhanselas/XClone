//
//  BlockUserManager.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

@Observable
class BlockingManager {
    var blockedUIDs = [String]()
    var blockedByUIDs = [String]()
    var didBlockUser = false
    
    private let service: BlockUserService
    
    init(service: BlockUserService) {
        self.service = service
        
        self.blockedUIDs = BlockedUsersCache.shared.getData()
        fetchBlockedByUsers()
    }
    
    func filterBlockedUsers(_ users: [User]) -> [User] {
        return users.filter(shouldDisplayUser)
    }
    
    func isBlocked(_ uid: String) -> Bool {
        return blockedUIDs.contains(uid) || blockedByUIDs.contains(uid)
    }
    
    private func shouldDisplayUser(_ user: User) -> Bool {
        let blockedByCurrentUser = blockedUIDs.contains(user.id)
        let userBlockedCurrentUser = blockedByUIDs.contains(user.id)
        
        return !blockedByCurrentUser && !userBlockedCurrentUser
    }
    
    private func fetchBlockedByUsers() {
        Task {
            self.blockedByUIDs = try await self.service.fetchBlockedByUsers()
        }
    }
}
