//
//  MockLikePostService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

class MockLikePostService: LikePostServiceProtocol {
    private var didCallLikePost = false
    private var didCallUnlikePost = false
    
    func likePost(_ post: Post) async throws {
        didCallLikePost = true
    }
    
    func unlikePost(_ post: Post) async throws {
        didCallUnlikePost = true
    }
    
    func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        return Bool.random()
    }    
}
