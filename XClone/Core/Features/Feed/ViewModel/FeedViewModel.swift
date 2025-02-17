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
    
    private var lastLoadTime: Date?
    private let refreshInterval: TimeInterval = 60 * 30
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
}
