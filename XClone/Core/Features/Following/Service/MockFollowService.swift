//
//  MockFollowService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Foundation

struct MockFollowService: FollowServiceProtocol {
    func follow(uid: String) async throws {
        
    }
    
    func unfollow(uid: String) async throws {
        
    }
    
    func fetchUserRelationState(uid: String) async throws -> UserRelationState {
        return .unknown
    }
}
