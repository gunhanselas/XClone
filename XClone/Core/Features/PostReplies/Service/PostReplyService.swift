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
        let postRef = FirestoreConstants.PostsCollection.document(postId)
        let replyRef = FirestoreConstants.postRepliesCollection(postId: postId).document()
        let batch = Firestore.firestore().batch()

        let reply = Post(
            id: replyRef.documentID,
            authorID: currentUid,
            timestamp: Date(),
            caption: caption,
            engagement: PostEngagement(),
            parentPostId: postId
        )
        
        let data = try Firestore.Encoder().encode(reply)
        
        batch.setData(data, forDocument: replyRef)
        batch.updateData(
            ["engagement.replyCount": FieldValue.increment(Int64(1))],
            forDocument: postRef
        )
        
        try await batch.commit()
    }
}
