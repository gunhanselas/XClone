//
//  MockProfileService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

struct MockProfileService: ProfileServiceProtocol {
    func fetchPosts(for uid: String) async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        return MockData.posts
    }
    
    func fetchReplies(for uid: String) async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        return MockData.posts
    }
    
    func fetchLikedPosts(for uid: String) async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        return MockData.likedPosts
    }
    
}
