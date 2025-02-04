//
//  LikePostService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/3/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol LikePostServiceProtocol {
    func likePost(_ post: Post) async throws
    func unlikePost(_ post: Post) async throws
    func checkIfUserLikedPost(_ post: Post) async throws -> Bool
}

struct LikePostService: LikePostServiceProtocol {
    private let cache = LikesCache.shared
    
    func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let postRef = FirestoreConstants.PostsCollection.document(post.id)
        let postLikesRef = postRef.collection("post-likes").document(uid)
        let userLikesRef = FirestoreConstants.userLikesCollection(uid: uid).document(post.id)
        
        batch.setData([:], forDocument: postLikesRef)
        batch.setData([:], forDocument: userLikesRef)
        batch.updateData(["engagement.likesCount": FieldValue.increment(Int64(1))], forDocument: postRef)
        
        try await batch.commit()
        
        cache.update(post.id, didAdd: true)
    }
    
    func unlikePost(_ post: Post) async throws {
        guard post.engagement.likesCount > 0 else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let postRef = FirestoreConstants.PostsCollection.document(post.id)
        let postLikesRef = postRef.collection("post-likes").document(uid)
        let userLikesRef = FirestoreConstants.userLikesCollection(uid: uid).document(post.id)
        
        batch.deleteDocument(postLikesRef)
        batch.deleteDocument(userLikesRef)
        batch.updateData(["engagement.likesCount": FieldValue.increment(Int64(-1))], forDocument: postRef)
        
        try await batch.commit()
        
        cache.update(post.id, didAdd: false)
    }
    
    func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        return cache.contains(post.id)
    }
}
