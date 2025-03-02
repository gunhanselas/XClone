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
    func updateNotificationsTAsRead(_ notifications: [XNotification]) async throws
}

struct XNotificationService: XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await FirestoreConstants
            .userNotificationsCollection(uid: currentUid)
            .limit(to: 50)
            .getDocuments(as: XNotification.self)
    }
    
    func updateNotificationsTAsRead(_ notifications: [XNotification]) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let batch = Firestore.firestore().batch()
        var documentRefs = [DocumentReference]()
        
        for notification in notifications where !notification.seen {
            let ref = FirestoreConstants
                .userNotificationsCollection(uid: currentUid)
                .document(notification.id)
            
            documentRefs.append(ref)
        }
        
        for documentRef in documentRefs {
            batch.updateData(["seen": true], forDocument: documentRef)
        }
        
        try await batch.commit()
    }
}
