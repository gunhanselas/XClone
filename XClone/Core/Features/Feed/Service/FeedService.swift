//
//  FeedService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

protocol FeedServiceProtocol {
    func fetchPosts() async throws -> [Post]
}

class FeedService: FeedServiceProtocol {
    func fetchPosts() async throws -> [Post] {
        return [] 
    }
}
