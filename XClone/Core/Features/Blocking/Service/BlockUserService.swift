//
//  BlockUserService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import FirebaseAuth
import FirebaseFirestore

struct BlockUserService {
    private let followService: FollowServiceProtocol
    
    init(followService: FollowServiceProtocol = FollowService()) {
        self.followService = followService
    }
    
    func blockUser(_ uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let batch = Firestore.firestore().batch()
        
        let blockedRef = FirestoreConstants.blockedUsersCollection(uid: currentUid).document(uid)
        let blockedByRef = FirestoreConstants.blockedByUsersCollection(uid: uid).document(currentUid)
        
        batch.setData([:], forDocument: blockedRef)
        batch.setData([:], forDocument: blockedByRef)
        
        try await batch.commit()
        try await followService.unfollow(uid: uid)
        
        BlockedUsersCache.shared.update(uid, didAdd: true)
    }
    
    func unblockUser(_ uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let batch = Firestore.firestore().batch()

        let blockedRef = FirestoreConstants.blockedUsersCollection(uid: currentUid).document(uid)
        let blockedByRef = FirestoreConstants.blockedByUsersCollection(uid: uid).document(currentUid)
        
        batch.deleteDocument(blockedRef)
        batch.deleteDocument(blockedByRef)
        
        try await batch.commit()
        
        BlockedUsersCache.shared.update(uid, didAdd: false)
    }
    
    func fetchBlockedByUsers() async throws -> [String] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let blockedByUsersSnapshot = try await FirestoreConstants.blockedByUsersCollection(uid: currentUid).getDocuments()
        return blockedByUsersSnapshot.documents.map { $0.documentID }
    }
}
