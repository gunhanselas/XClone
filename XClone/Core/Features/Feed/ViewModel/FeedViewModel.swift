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
    }
    
    func fetchPosts() async {
        do {
            self.posts = try await feedService.fetchPosts()
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            print("DEBUG: Failed to fetch posts with error: \(error)")
            loadingState = .error(error)
        }
    }
}
