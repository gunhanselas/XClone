//
//  FollowService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol FollowServiceProtocol {
    func follow(uid: String) async throws
    func unfollow(uid: String) async throws
    func fetchUserRelationState(uid: String) async throws -> UserRelationState
}

struct FollowService: FollowServiceProtocol {
    func follow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let followingRef = FirestoreConstants
            .userFollowingCollection(uid: currentUid)
            .document(uid)
        
        let followerRef = FirestoreConstants
            .userFollowerCollection(uid: uid)
            .document(currentUid)
        
        batch.setData([:], forDocument: followingRef)
        batch.setData([:], forDocument: followerRef)
        
        try await batch.commit()
    }
    
    func unfollow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let followingRef = FirestoreConstants
            .userFollowingCollection(uid: currentUid)
            .document(uid)
        
        let followerRef = FirestoreConstants
            .userFollowerCollection(uid: uid)
            .document(currentUid)
        
        batch.deleteDocument(followingRef)
        batch.deleteDocument(followerRef)
        
        try await batch.commit()
    }
    
    func fetchUserRelationState(uid: String) async throws -> UserRelationState {
        guard let currentUid = Auth.auth().currentUser?.uid else { return .unknown }
        
        let isFollowed = try await FirestoreConstants
            .userFollowingCollection(uid: currentUid)
            .document(uid)
            .getDocument()
        
        if isFollowed.exists { return .followed }
        
        return .notFollowed
    }
}
