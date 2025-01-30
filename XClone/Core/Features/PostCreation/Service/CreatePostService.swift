//
//  CreatePostService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Foundation

protocol CreatePostServiceProtocol {
    func uploadPost(caption: String, imageData: Data) async throws
}

struct CreatePostService: CreatePostServiceProtocol {
    func uploadPost(caption: String, imageData: Data) async throws {
        
    }
}
