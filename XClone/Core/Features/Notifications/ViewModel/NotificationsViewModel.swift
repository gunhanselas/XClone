//
//  NotificationsViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import SwiftUI

@Observable
class NotificationsViewModel {
    var loadingState: ContentLoadingState = .loading
    var notifications = [XNotification]()
    
    private let service: XNotificationServiceProtocol
    private let userService: UserServiceProtocol
    
    init(
        service: XNotificationServiceProtocol = XNotificationService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.service = service
        self.userService = userService
    }
    
    func fetchNotifications() async {
        do {
            notifications = try await service.fetchNotifications()
            try await fetchNotificationUserData()
            loadingState = notifications.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
            print("DEBUG: Failed to fetch notifications with error: \(error)")
        }
    }
    
    private func fetchNotificationUserData() async throws {
        try await withThrowingTaskGroup(of: (Int, User?).self) { [weak self] group in
            guard let self else { return }
            
            for (index, notification) in self.notifications.enumerated() {
                group.addTask {
                    let user = try await self.userService.fetchUser(withUid: notification.senderID)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                notifications[index].sender = user
            }
        }
    }
}
