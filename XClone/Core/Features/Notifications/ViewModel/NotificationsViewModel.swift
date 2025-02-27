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
    private let postService: PostServiceProtocol
    
    init(
        service: XNotificationServiceProtocol = XNotificationService(),
        userService: UserServiceProtocol = UserService(),
        postService: PostServiceProtocol = PostService()
    ) {
        self.service = service
        self.userService = userService
        self.postService = postService
    }
    
    func fetchNotifications() async {
        guard notifications.isEmpty else { return }
        
        do {
            notifications = try await service.fetchNotifications()
            await fetchNotificationMetadata()
            loadingState = notifications.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
            print("DEBUG: Failed to fetch notifications with error: \(error)")
        }
    }
    
    private func fetchNotificationMetadata() async {
        await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            
            group.addTask { try await self.fetchNotificationUserData() }
            group.addTask { try await self.fetchNotificationPostDataIfNecessary() }
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
    
    private func fetchNotificationPostDataIfNecessary() async throws {
        try await withThrowingTaskGroup(of: (Int, Post?).self) { [weak self] group in
            guard let self else { return }
            
            for (index, notification) in self.notifications.enumerated() {
                guard let postID = notification.postId else { continue }
                
                group.addTask {
                    let post = try await self.postService.fetchPost(with: postID)
                    return (index, post)
                }
            }
            
            for try await (index, post) in group {
                notifications[index].post = post
            }
        }
    }
}
