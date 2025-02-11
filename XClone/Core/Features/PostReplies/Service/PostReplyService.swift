//
//  PostReplyService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol PostReplyServiceProtocol {
    func uploadReply(caption: String, to postID: String) async throws
}

struct PostReplyService: PostReplyServiceProtocol {
    func uploadReply(caption: String, to postID: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postRef = FirestoreConstants.PostsCollection.document(postID)
        let replyRef = FirestoreConstants.postRepliesCollection(postId: postID).document()
        let userReplyRef = FirestoreConstants.userRepliesCollection(uid: currentUid).document(postID)
        
        let batch = Firestore.firestore().batch()

        let reply = Post(
            id: replyRef.documentID,
            authorID: currentUid,
            timestamp: Date(),
            caption: caption,
            engagement: PostEngagement(),
            parentPostId: postID
        )
        
        let replyData = try Firestore.Encoder().encode(reply)
        
        batch.setData(replyData, forDocument: replyRef)
        batch.updateData(
            ["engagement.replyCount": FieldValue.increment(Int64(1))],
            forDocument: postRef
        )
        
        let userReply = UserPostReply(uid: currentUid, postId: postID, timestamp: Date())
        let userReplyData = try Firestore.Encoder().encode(userReply)
        
        batch.setData(userReplyData, forDocument: userReplyRef)
        
        try await batch.commit()
    }
}
