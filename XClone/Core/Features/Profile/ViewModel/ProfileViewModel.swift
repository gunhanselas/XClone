//
//  ProfileViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

@Observable
class ProfileViewModel: FeedViewModelProtocol {
    
    var currentDataSource = [Post]()
    var loadingState: ContentLoadingState = .loading

    var posts = [Post]()
    private var replies = [Post]()
    private var likedPosts = [Post]()
    
    private let profileService: ProfileServiceProtocol
    private(set) var likeService: LikePostServiceProtocol

    init(profileService: ProfileServiceProtocol, likeService: LikePostServiceProtocol = LikePostService()) {
        self.profileService = profileService
        self.likeService = likeService
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
    
    func fetchContent(for uid: String) async {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchPosts(for: uid) }
            group.addTask { await self.fetchReplies(for: uid) }
            group.addTask { await self.fetchedLikedPosts(for: uid) }
        }
    }
    
    private func fetchPosts(for uid: String) async {
        do {
            self.posts = try await profileService.fetchPosts(for: uid)
            setCurrentDataSource(for: .posts)
        } catch {
            print("DEBUG: Error fetching posts: \(error)")
        }
    }
    
    private func fetchReplies(for uid: String) async {
        do {
            self.replies = try await profileService.fetchReplies(for: uid)
        } catch {
            print("DEBUG: Error fetching posts: \(error)")
        }
    }
    
    private func fetchedLikedPosts(for uid: String) async {
        do {
            self.likedPosts = try await profileService.fetchLikedPosts(for: uid)
        } catch {
            print("DEBUG: Error fetching posts: \(error)")
        }
    }
}
