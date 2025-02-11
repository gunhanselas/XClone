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
}
