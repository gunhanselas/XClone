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
    private let userService: UserServiceProtocol
    
    private(set) var likeService: LikePostServiceProtocol

    init(
        user: User,
        profileService: ProfileServiceProtocol = ProfileService(),
        likeService: LikePostServiceProtocol = LikePostService(),
        followService: FollowServiceProtocol = FollowService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.user = user
        self.profileService = profileService
        self.likeService = likeService
        self.followService = followService
        self.userService = userService
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
    
    func refresh() async {
        do {
            self.user = try await userService.fetchUser(withUid: user.id)
            
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self else { return }
                group.addTask { await self.fetchUserRelationState() }
                group.addTask { await self.fetchUserContent() }
            }
        } catch {
            print("DEBUG: Failed to refresh profile with error: \(error)")
        }
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
            var posts = try await profileService.fetchPosts(for: uid)
            
            for (index, post) in posts.enumerated() {
                posts[index].author = self.user
            }
            
            self.posts = posts
            setCurrentDataSource(for: .posts)
        } catch {
            print("DEBUG: Error fetching posts: \(error)")
        }
    }
    
    func fetchReplies(for uid: String) async {
        do {
            let replies = try await profileService.fetchReplies(for: uid)
            self.replies = try await fetchUserData(for: replies)
        } catch {
            print("DEBUG: Error fetching replies: \(error)")
        }
    }
    
    func fetchedLikedPosts(for uid: String) async {
        do {
            let likedPosts = try await profileService.fetchLikedPosts(for: uid)
            self.likedPosts = try await fetchUserData(for: likedPosts)
        } catch {
            print("DEBUG: Error fetching liked posts: \(error)")
        }
    }
    
    func fetchUserData(for posts: [Post]) async throws -> [Post] {
        var result = posts
        
        try await withThrowingTaskGroup(of: (Int, User?).self) { [weak self] group in
            guard let self else { return }
            
            for (index, post) in posts.enumerated() {
                group.addTask {
                    let user = try await self.userService.fetchUser(withUid: post.authorID)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                result[index].author = user
            }
        }
        
        return result
    }
}
