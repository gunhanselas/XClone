//
//  FeedViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

@Observable
class FeedViewModel {
    var loadingState: ContentLoadingState = .loading
    var posts = [Post]()
    
    private let service: FeedServiceProtocol
    
    init(service: FeedServiceProtocol) {
        self.service = service
    }
    
    func fetchPosts() async {
        do {
            self.posts = try await service.fetchPosts()
            loadingState = posts.isEmpty ? .empty : .complete
        } catch {
            print("DEBUG: Failed to fetch posts with error: \(error)")
            loadingState = .error(error)
        }
    }
    
}
