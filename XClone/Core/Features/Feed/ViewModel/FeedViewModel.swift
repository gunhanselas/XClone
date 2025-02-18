//
//  FeedViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

@Observable
class FeedViewModel: FeedViewModelProtocol {
    var loadingState: ContentLoadingState = .loading
    var posts = [Post]()
    
    private let feedService: FeedServiceProtocol
    let likeService: LikePostServiceProtocol
    
    init(
        feedService: FeedServiceProtocol = FeedService(),
        likeService: LikePostServiceProtocol = LikePostService()
    ) {
        self.feedService = feedService
        self.likeService = likeService
        
        Task { await fetchPosts() }
    }
    
    func fetchPosts() async {
        do {
            let posts = try await feedService.fetchPosts()
            try await fetchPostUserData(for: posts)
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            print("DEBUG: Failed to fetch posts with error: \(error)")
            loadingState = .error(error)
        }
    }
    
    func refreshFeed() async {
        do {
            let posts = try await feedService.refreshFeed()
            try await fetchPostUserData(for: posts)
        } catch {
            print("DEBUG: Failed to refresh posts with error: \(error)")
            loadingState = .error(error)
        }
    }
}
