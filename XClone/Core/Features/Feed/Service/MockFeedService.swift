//
//  MockFeedService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

class MockFeedService: FeedServiceProtocol {
    func fetchPosts() async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        return MockData.posts
    }
}
