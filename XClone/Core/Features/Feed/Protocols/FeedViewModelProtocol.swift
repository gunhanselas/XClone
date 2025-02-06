//
//  FeedViewModelProtocol.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

@MainActor
protocol FeedViewModelProtocol: ObservableObject {
    var posts: [Post] { get set }
    var likeService: LikePostServiceProtocol { get }
}

extension FeedViewModelProtocol {
    func likePost(_ post: Post) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        do {
            self.posts[index].didLike = true
            posts[index].engagement.likesCount += 1
            try await likeService.likePost(post)
        } catch {
            posts[index].didLike = false
            posts[index].engagement.likesCount -= 1
            print("DEBUG: Failed to like post with error: \(error)")
        }
    }
    
    func unlikePost(_ post: Post) async {
        guard post.didLike,
              post.engagement.likesCount > 0,
              let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        do {
            posts[index].didLike = false
            posts[index].engagement.likesCount -= 1
            try await likeService.unlikePost(post)
        } catch {
            posts[index].didLike = true
            posts[index].engagement.likesCount += 1
            print("DEBUG: Failed to unlike post with error: \(error)")
        }
    }
}
