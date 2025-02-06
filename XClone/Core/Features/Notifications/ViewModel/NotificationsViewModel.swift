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
    
    init(service: XNotificationServiceProtocol = MockXNotificationService()) {
        self.service = service
    }
    
    func fetchNotifications() async {
        do {
            notifications = try await service.fetchNotifications()
            loadingState = notifications.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
            print("DEBUG: Failed to fetch notifications with error: \(error)")
        }
    }
}
