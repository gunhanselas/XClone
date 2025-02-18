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
    var replies = [Post]()
    
    private let service: PostDetailServiceProtocol
    private(set) var likeService: LikePostServiceProtocol
    
    init(
        post: Post,
        service: PostDetailServiceProtocol = PostDetailService(),
        likePostService: LikePostServiceProtocol = LikePostService()
    ) {
        self.posts = [post]
        self.service = service
        self.likeService = likePostService
    }
    
    func fetchReplies(for post: Post, sortOption: ReplySortModel) async {
        loadingState = .loading
        
        do {
            self.replies = try await service.fetchReplies(for: post, sortOption: sortOption)
            try await fetchUserDataForReplies()
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
        }
    }
    
    private func fetchUserDataForReplies() async throws {
        try await withThrowingTaskGroup(of: (Int, User).self) { group in
            for (index, reply) in replies.enumerated() {
                group.addTask {
                    let user = try await FirestoreConstants.UserCollection.document(reply.authorID).getDocument(as: User.self)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                replies[index].author = user
            }
        }
    }
}
