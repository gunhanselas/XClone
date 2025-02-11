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
    private let notificationService: SendNotificationService
    
    init(notificationService: SendNotificationService = SendNotificationService()) {
        self.notificationService = notificationService
    }
    
    func follow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        
        let followingRef = FirestoreConstants.userFollowingCollection(uid: currentUid).document(uid)
        let followerRef = FirestoreConstants.userFollowerCollection(uid: uid).document(currentUid)
        let currentUserStatRef = FirestoreConstants.UserCollection.document(currentUid)
        let followedUserStatRef = FirestoreConstants.UserCollection.document(uid)
        
        batch.setData([:], forDocument: followingRef)
        batch.setData([:], forDocument: followerRef)
        batch.updateData(["followStats.followingCount": FieldValue.increment(Int64(1))], forDocument: currentUserStatRef)
        batch.updateData(["followStats.followersCount": FieldValue.increment(Int64(1))], forDocument: followedUserStatRef)

        try await batch.commit()
        try await notificationService.sendFollowNotification(toUid: uid)
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
        
        let currentUserStatRef = FirestoreConstants.UserCollection.document(currentUid)
        let unfollowedUserStatRef = FirestoreConstants.UserCollection.document(uid)
        
        batch.deleteDocument(followingRef)
        batch.deleteDocument(followerRef)
        batch.updateData(["followStats.followingCount": FieldValue.increment(Int64(-1))], forDocument: currentUserStatRef)
        batch.updateData(["followStats.followersCount": FieldValue.increment(Int64(-1))], forDocument: unfollowedUserStatRef)
        
        try await batch.commit()
        await notificationService.deleteFollowNotification(notificationOwnerUid: uid)
    }
    
    func fetchUserRelationState(uid: String) async throws -> UserRelationState {
        guard let currentUid = Auth.auth().currentUser?.uid else { return .unknown }

        if currentUid == uid { return .isCurrentUser }
        
        let isFollowed = try await FirestoreConstants
            .userFollowingCollection(uid: currentUid)
            .document(uid)
            .getDocument()
        
        if isFollowed.exists { return .followed }
        
        return .notFollowed
    }
}
