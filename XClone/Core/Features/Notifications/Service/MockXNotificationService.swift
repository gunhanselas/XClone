//
//  MockXNotificationService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

struct MockXNotificationService: XNotificationServiceProtocol {
    func fetchNotifications() async throws -> [XNotification] {
        try await Task.sleep(for: .seconds(1))
        return MockData.notifications
    }
}
