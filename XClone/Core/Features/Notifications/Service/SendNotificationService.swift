//
//  SendNotificationService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct SendNotificationService {
    func sendLikeNotification(toUid uid: String, post: Post) {
        sendNotification(toUid: uid, type: .like, post: post)
    }
    
    func sendReplyNotification(toUid uid: String, post: Post) {
        sendNotification(toUid: uid, type: .reply, post: post)
    }
    
    func sendFollowNotification(toUid uid: String) {
        sendNotification(toUid: uid, type: .follow)
    }
    
    func deleteLikeNotification(notificationOwnerUid: String, post: Post) async {
        do {
            try await deleteNotification(toUid: notificationOwnerUid, type: .like, post: post)
        } catch {
            print("DEBUG: Failed to delete like notification")
        }
    }
    
    func deleteFollowNotification(notificationOwnerUid: String) async {
        do {
            try await deleteNotification(toUid: notificationOwnerUid, type: .follow)
        } catch {
            print("DEBUG: Failed to delete follow notification")
        }
    }
    
    private func sendNotification(toUid uid: String, type: XNotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid, uid != currentUid else { return }
        let ref = FirestoreConstants.userNotificationsCollection(uid: uid).document()
        let notif = XNotification(id: ref.documentID, type: type, senderID: currentUid, timestamp: Date(), postId: post?.id)
        guard let data = try? Firestore.Encoder().encode(notif) else { return }
        ref.setData(data)
    }
    
    private func deleteNotification(toUid uid: String, type: XNotificationType, post: Post? = nil) async throws {
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
