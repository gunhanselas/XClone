//
//  PostDetailViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Observation

@Observable
class PostDetailViewModel: FeedViewModelProtocol {
    var loadingState: ContentLoadingState = .loading
    var posts = [Post]()
    
    private let service: PostDetailServiceProtocol
    private(set) var likeService: LikePostServiceProtocol
    
    init(service: PostDetailServiceProtocol, likePostService: LikePostServiceProtocol = LikePostService()) {
        self.service = service
        self.likeService = likePostService
    }
    
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async {
        loadingState = .loading
        
        do {
            self.posts = try await service.fetchReplies(for: post, sortOption: sortOption)
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
        }
    }
}
