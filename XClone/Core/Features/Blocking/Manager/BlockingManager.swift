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
    
    func unblockUser(_ user: User) async {
        guard let index = blockedUIDs.firstIndex(where: { $0 == user.id }) else { return }
        
        do {
            try await service.unblockUser(user.id)
            blockedUIDs.remove(at: index)
        } catch {
            print("DEBUG: Failed to unblock user with error: \(error.localizedDescription)")
        }
    }
    
    func blockUser(_ uid: String) async {
        do {
            try await service.blockUser(uid)
            blockedUIDs.append(uid)
        } catch {
            print("DEBUG: Failed to block user with error: \(error.localizedDescription)")
        }
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
