//
//  FirestoreConstants.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Firebase

struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    
    static let UserCollection = Root.collection("users")
    static let PostsCollection = Root.collection("posts")
    static let ThreadsCollection = Root.collection("threads")
    static let ReportsCollection = Root.collection("reports")
    
    static func blockedUsersCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("blocked-users")
    }
    
    static func blockedByUsersCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("blocked-users")
    }
    
    static func deletedThreadsCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("deleted-threads")
    }

    static func messagesCollection(threadID: String) -> CollectionReference {
        return ThreadsCollection.document(threadID).collection("messages")
    }
    
    static func postLikesCollection(postId: String) -> CollectionReference {
        return PostsCollection.document(postId).collection("post-likes")
    }
    
    static func postRepliesCollection(postId: String) -> CollectionReference {
        return PostsCollection.document(postId).collection("post-replies")
    }
    
    static func userFeedCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-feed")
    }
    
    static func userNotificationsCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-notifications")
    }
    
    static func userFollowerCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-followers")
    }
    
    static func userFollowingCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-following")
    }
    
    static func userLikesCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-likes")
    }
    
    static func userRepliesCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-replies")
    }
}
