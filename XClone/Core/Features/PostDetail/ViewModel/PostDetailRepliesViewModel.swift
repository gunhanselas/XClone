//
//  PostDetailRepliesViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/19/25.
//

import Foundation

import Observation

@Observable
class PostDetailRepliesViewModel: FeedViewModelProtocol {
    var loadingState: ContentLoadingState = .loading
    var posts = [Post]()
    
    private let service: PostDetailServiceProtocol
    
    init(service: PostDetailServiceProtocol = PostDetailService()) {
        self.service = service
    }
    
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async {
        loadingState = .loading
        
        do {
            self.posts = try await service.fetchReplies(for: post, sortOption: sortOption)
            try await fetchUserDataForReplies()
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
        }
    }
    
    private func fetchUserDataForReplies() async throws {
        try await withThrowingTaskGroup(of: (Int, User).self) { group in
            for (index, reply) in posts.enumerated() {
                group.addTask {
                    let user = try await FirestoreConstants.UserCollection.document(reply.authorID).getDocument(as: User.self)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                posts[index].author = user
            }
        }
    }
}
