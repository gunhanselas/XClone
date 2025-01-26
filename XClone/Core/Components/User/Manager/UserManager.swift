//
//  UserManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

@Observable
class UserManager {
    var currentUser: User?
    
    private let service: UserServiceProtocol
    
    init(service: UserServiceProtocol) {
        self.service = service
    }
    
    func fetchCurrentUser() async {
        do {
            self.currentUser = try await service.fetchCurrentUser()
            self.currentUser?.userRelationState = .isCurrentUser
        } catch {
            print("DEBUG: Error fetching current user: \(error)")
        }
    }
}
