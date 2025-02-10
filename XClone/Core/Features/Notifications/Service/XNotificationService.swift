//
//  XNotificationService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification]
}

struct XNotificationService: XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await FirestoreConstants
            .userNotificationsCollection(uid: currentUid)
            .getDocuments(as: XNotification.self)
    }
    
    func uploadNotification(toUid uid: String, type: XNotificationType, post: Post? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid, uid != currentUid else { return }
        let ref = FirestoreConstants.userNotificationsCollection(uid: uid).document()
        
        let notification = XNotification(
            id: ref.documentID,
            type: type,
            senderID: currentUid,
            timestamp: Date(),
            postId: post?.id
        )
        
        let data = try Firestore.Encoder().encode(notification)
        try await ref.setData(data)
    }
    
    func deleteNotification(toUid uid: String, type: XNotificationType, post: Post? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let notifications = try await FirestoreConstants
            .userNotificationsCollection(uid: uid)
            .whereField("senderID", isEqualTo: currentUid)
            .getDocuments(as: XNotification.self)
        
        let filteredByType = notifications.filter { $0.type == type }
        
        if type == .follow {
            for notification in filteredByType {
                try await FirestoreConstants
                    .userNotificationsCollection(uid: uid)
                    .document(notification.id)
                    .delete()
            }
        } else {
            guard let notificationToDelete = filteredByType.first(where: { $0.postId == post?.id }) else { return }
            
            try await FirestoreConstants
                .userNotificationsCollection(uid: uid)
                .document(notificationToDelete.id)
                .delete()
        }
    }
}
