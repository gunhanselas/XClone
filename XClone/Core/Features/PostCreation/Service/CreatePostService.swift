//
//  CreatePostService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol CreatePostServiceProtocol {
    func uploadPost(caption: String, imageData: Data?) async throws
}

struct CreatePostService: CreatePostServiceProtocol {
    func uploadPost(caption: String, imageData: Data?) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postRef = FirestoreConstants.PostsCollection.document()
        
        var post = Post(
            id: postRef.documentID,
            authorID: currentUid,
            timestamp: Date(),
            caption: caption,
            engagement: PostEngagement()
        )
        
        if let imageData {
            post.imageURL = try await ImageUploader().uploadImage(imageData: imageData, type: .post)
        }
        
        let data = try Firestore.Encoder().encode(post)
        try await postRef.setData(data)
    }
}
