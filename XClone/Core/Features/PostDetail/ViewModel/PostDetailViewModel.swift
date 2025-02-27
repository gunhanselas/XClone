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
        
    init(post: Post) {
        self.posts = [post]
    }
}
