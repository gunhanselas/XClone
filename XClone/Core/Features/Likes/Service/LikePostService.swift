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
    
    private let notificationService: SendNotificationService
    
    init(notificationService: SendNotificationService = SendNotificationService()) {
        self.notificationService = notificationService
    }
    
    func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        let timestamp = Date()
        
        let postRef: DocumentReference
        
        if let parentPostId = post.parentPostId {
            postRef = FirestoreConstants.postRepliesCollection(postId: parentPostId).document(post.id)
        } else {
            postRef = FirestoreConstants.PostsCollection.document(post.id)
        }
        
        let userLikesRef = FirestoreConstants.userLikesCollection(uid: uid).document(post.id)
        
        if !post.isReply {
            let postLikesRef = postRef.collection("post-likes").document(uid)
            batch.setData(["timestamp": timestamp], forDocument: postLikesRef)
        }
        
        batch.setData(["timestamp": timestamp], forDocument: userLikesRef)
        batch.updateData(["engagement.likesCount": FieldValue.increment(Int64(1))], forDocument: postRef)
        
        try await batch.commit()
        
        cache.update(post.id, didAdd: true)
        
        try await notificationService.sendLikeNotification(toUid: post.authorID, post: post)
    }
    
    func unlikePost(_ post: Post) async throws {
        guard post.engagement.likesCount > 0 else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let postRef: DocumentReference
        
        if let parentPostId = post.parentPostId {
            postRef = FirestoreConstants.postRepliesCollection(postId: parentPostId).document(post.id)
        } else {
            postRef = FirestoreConstants.PostsCollection.document(post.id)
        }

        let postLikesRef = postRef.collection("post-likes").document(uid)
        let userLikesRef = FirestoreConstants.userLikesCollection(uid: uid).document(post.id)
        
        batch.deleteDocument(postLikesRef)
        batch.deleteDocument(userLikesRef)
        batch.updateData(["engagement.likesCount": FieldValue.increment(Int64(-1))], forDocument: postRef)
        
        try await batch.commit()
        
        cache.update(post.id, didAdd: false)
        
        await notificationService.deleteLikeNotification(notificationOwnerUid: post.authorID, post: post)
    }
    
    func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        return cache.contains(post.id)
    }
}
