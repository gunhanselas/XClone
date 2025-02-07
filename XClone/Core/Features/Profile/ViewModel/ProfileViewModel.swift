//
//  ProfileViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

@Observable
class ProfileViewModel: FeedViewModelProtocol {
    var user: User
    var currentDataSource = [Post]()
    var loadingState: ContentLoadingState = .loading

    var posts = [Post]()
    var replies = [Post]()
    var likedPosts = [Post]()
    
    private let profileService: ProfileServiceProtocol
    private let followService: FollowServiceProtocol
    private(set) var likeService: LikePostServiceProtocol

    init(
        user: User,
        profileService: ProfileServiceProtocol = MockProfileService(),
        likeService: LikePostServiceProtocol = LikePostService(),
        followService: FollowServiceProtocol = FollowService()
    ) {
        self.user = user
        self.profileService = profileService
        self.likeService = likeService
        self.followService = followService
    }
    
    func setCurrentDataSource(for filter: ProfileContentFilterModel) {
        loadingState = .loading
        
        switch filter {
        case .posts:
            self.currentDataSource = posts
        case .replies:
            self.currentDataSource = replies
        case .likes:
            self.currentDataSource = likedPosts
        }
        
        loadingState = currentDataSource.isEmpty ? .empty : .complete
    }
    
    func fetchUserContent() async {
        await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            
            group.addTask { await self.fetchPosts(for: self.user.id) }
            group.addTask { await self.fetchReplies(for: self.user.id) }
            group.addTask { await self.fetchedLikedPosts(for: self.user.id) }
        }
    }
    
    func fetchUserRelationState() async {
        do {
            self.user.userRelationState = try await followService.fetchUserRelationState(uid: user.id)
        } catch {
            print("DEBUG: Failed to fetch user relation state with error: \(error)")
        }
    }
    
    func follow() async {
        let prevState = user.userRelationState
        
        do {
            user.userRelationState = .followed
            user.followStats.followersCount += 1
            try await followService.follow(uid: user.id)
        } catch {
            user.userRelationState = prevState
            user.followStats.followersCount -= 1
            print("DEBUG: Failed to follow user with error: \(error.localizedDescription)")
        }
    }
    
    func unfollow() async {
        let prevState = user.userRelationState
        
        do {
            user.userRelationState = .notFollowed
            user.followStats.followersCount -= 1
            try await followService.unfollow(uid: user.id)
        } catch {
            user.userRelationState = prevState
            user.followStats.followersCount += 1
            print("DEBUG: Failed to unfollow user with error: \(error.localizedDescription)")
        }
    }
}

private extension ProfileViewModel {
    func fetchPosts(for uid: String) async {
        do {
            self.posts = try await profileService.fetchPosts(for: uid)
            setCurrentDataSource(for: .posts)
        } catch {
            print("DEBUG: Error fetching posts: \(error)")
        }
    }
    
    func fetchReplies(for uid: String) async {
        do {
            self.replies = try await profileService.fetchReplies(for: uid)
        } catch {
            print("DEBUG: Error fetching replies: \(error)")
        }
    }
    
    func fetchedLikedPosts(for uid: String) async {
        do {
            self.likedPosts = try await profileService.fetchLikedPosts(for: uid)
        } catch {
            print("DEBUG: Error fetching liked posts: \(error)")
        }
    }
}
