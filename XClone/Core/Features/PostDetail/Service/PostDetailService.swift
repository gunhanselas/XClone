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
        switch sortOption {
        case .mostRecent:
            return try await fetchMostRecentReplies(for: post.id)
        case .mostLiked:
            return try await fetchMostLikedReplies(for: post.id)
        }
    }
    
    private func fetchMostRecentReplies(for postID: String) async throws -> [Post] {
        return try await FirestoreConstants
            .postRepliesCollection(postId: postID)
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
    }
    
    private func fetchMostLikedReplies(for postID: String) async throws -> [Post] {
        return try await FirestoreConstants
            .postRepliesCollection(postId: postID)
            .order(by: "engagement.likesCount", descending: true)
            .getDocuments(as: Post.self)
    }
}
