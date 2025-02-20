//
//  PostDetailViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Observation

@Observable
class PostDetailViewModel: FeedViewModelProtocol {
    var posts = [Post]()
    
    private(set) var likeService: LikePostServiceProtocol
    
    init(
        post: Post,
        likePostService: LikePostServiceProtocol = LikePostService()
    ) {
        self.posts = [post]
        self.likeService = likePostService
    }
}
