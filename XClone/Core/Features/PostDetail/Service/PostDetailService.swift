//
//  PostDetailService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

protocol PostDetailServiceProtocol {
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async throws -> [Post]
}

struct PostDetailService: PostDetailServiceProtocol {
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        
        switch sortOption {
        case .mostRecent:
            return MockData.posts.sorted(by: { $0.timestamp > $1.timestamp })
        case .mostLiked:
            return MockData.posts.sorted(by: { $0.engagement.likesCount > $1.engagement.likesCount })
        }
    }
}
