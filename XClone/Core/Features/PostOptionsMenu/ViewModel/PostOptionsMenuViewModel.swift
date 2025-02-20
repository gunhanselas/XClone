//
//  PostOptionsMenuViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

@Observable
class PostOptionsMenuViewModel {
    private let blockingService: BlockUserService
    private let followService: FollowServiceProtocol
    private let postService: PostService
    
    init(
        blockingService: BlockUserService = BlockUserService(),
        followService: FollowServiceProtocol = FollowService(),
        postService: PostService = PostService()
    ) {
        self.blockingService = blockingService
        self.followService = followService
        self.postService = postService
    }
    
    func blockUser(_ uid: String) async {
        do {
            try await blockingService.blockUser(uid)
        } catch {
            print("DEBUG: Failed to block user with error: \(error)")
        }
    }
    
    func deletePost(_ post: Post) async {
        do {
            try await postService.deletePost(post)
        } catch {
            print("DEBUG: Failed to delete post with error: \(error)")
        }
    }
    
    func fetchUserRelationState(_ uid: String) async -> UserRelationState {
        do {
            return try await followService.fetchUserRelationState(uid: uid)
        } catch {
            print("DEBUG: Failed to fetch relation state with error: \(error)")
            return .unknown
        }
    }
    
    func follow(_ uid: String) async {
        do {
            try await followService.follow(uid: uid)
        } catch {
            print("DEBUG: Failed to follow user with error: \(error)")
        }
    }
    
    func unfollow(_ uid: String) async {
        do {
            try await followService.unfollow(uid: uid)
        } catch {
            print("DEBUG: Failed to unfollow user with error: \(error)")
        }
    }
}
