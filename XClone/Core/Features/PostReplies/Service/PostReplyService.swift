//
//  PostReplyService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol PostReplyServiceProtocol {
    func uploadReply(caption: String) async throws
}

struct PostReplyService: PostReplyServiceProtocol {
    private let postId: String
    
    init(postId: String) {
        self.postId = postId
    }
    
    func uploadReply(caption: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let replyRef = FirestoreConstants.postRepliesCollection(postId: postId).document()
        
        let reply = Post(
            id: replyRef.documentID,
            authorID: currentUid,
            timestamp: Date(),
            caption: caption,
            engagement: PostEngagement(),
            parentPostId: postId
        )
        
        let data = try Firestore.Encoder().encode(reply)
        try await replyRef.setData(data)
    }
}
