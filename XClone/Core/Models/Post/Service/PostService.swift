//
//  PostService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import FirebaseStorage
import Foundation

protocol PostServiceProtocol {
    func deletePost(_ post: Post) async throws
    func fetchPost(with postID: String) async throws -> Post
}

struct PostService: PostServiceProtocol {
    func deletePost(_ post: Post) async throws {
        if let imageURL = post.imageURL {
            try await Storage.storage().reference(forURL: imageURL).delete()
        }
        
        try await FirestoreConstants.PostsCollection.document(post.id).delete()
    }
    
    func fetchPost(with postID: String) async throws -> Post {
        return try await FirestoreConstants.PostsCollection.document(postID).getDocument(as: Post.self)
    }
}
