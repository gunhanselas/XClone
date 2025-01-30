//
//  FirestoreConstants.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

@preconcurrency import Firebase

struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    
    static let UserCollection = Root.collection("users")
    static let PostsCollection = Root.collection("posts")
    static let MessagesCollection = Root.collection("messages")
    static let NotificationsCollection = Root.collection("notifications")
    
    static func postLikesCollection(postId: String) -> CollectionReference {
        return PostsCollection.document(postId).collection("post-likes")
    }
    
    static func userFeedCollection(uid: String) -> CollectionReference {
        return UserCollection.document(uid).collection("user-feed")
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
}
