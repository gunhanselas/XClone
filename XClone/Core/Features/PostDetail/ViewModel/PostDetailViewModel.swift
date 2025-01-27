//
//  PostDetailViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Observation

@Observable
class PostDetailViewModel {
    var loadingState: ContentLoadingState = .loading
    var replies = [Post]()
    
    private let service: PostDetailServiceProtocol
    
    init(service: PostDetailServiceProtocol) {
        self.service = service
    }
    
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async {
        loadingState = .loading
        
        do {
            self.replies = try await service.fetchReplies(for: post, sortOption: sortOption)
            loadingState = replies.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
        }
    }
}
