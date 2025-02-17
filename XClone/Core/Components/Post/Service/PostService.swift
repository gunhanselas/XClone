//
//  PostService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import FirebaseStorage
import Foundation

struct PostService {
    func deletePost(_ post: Post) async throws {
        if let imageURL = post.imageURL {
            try await Storage.storage().reference(forURL: imageURL).delete()
        }
        
        try await FirestoreConstants.PostsCollection.document(post.id).delete()
    }
}
