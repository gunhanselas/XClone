//
//  XNotificationService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

protocol XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification]
}

struct XNotificationService: XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification] {
        return []
    }
}
