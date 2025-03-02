//
//  NotificationsViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import SwiftUI

@Observable
class NotificationsViewModel: FeedViewModelProtocol {
    var loadingState: ContentLoadingState = .loading
    var notifications = [XNotification]()
    var unreadNotificationsCount = 0
    var posts = [Post]()
    
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
        
        Task { await fetchNotifications() }
    }
    
    func fetchNotifications() async {
        guard notifications.isEmpty else { return }
        
        do {
            notifications = try await service.fetchNotifications()
            setUnreadNotificationCount()
            
            await fetchNotificationMetadata()
            loadingState = notifications.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
            print("DEBUG: Failed to fetch notifications with error: \(error)")
        }
    }
    
    func refreshNotifications() async {
        notifications.removeAll()
        await fetchNotifications()
    }
    
    private func setUnreadNotificationCount() {
        self.unreadNotificationsCount = notifications.count(where: { $0.seen == false })
    }
    
    func updateNotifcationsAsRead() async {
        do {
            try await service.updateNotificationsTAsRead(self.notifications)
            self.unreadNotificationsCount = 0
        } catch {
            print("DEBUG: Failed to update notification status with error: \(error)")
        }
    }
    
    private func fetchNotificationMetadata() async {
        do {
            try await self.fetchNotificationUserData()
            try await self.fetchNotificationPostDataIfNecessary()
        } catch {
            print("DEBUG: Failed to fetch notification metadata with error: \(error)")
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
        var updatedNotifications = notifications

        try await withThrowingTaskGroup(of: (Int, Post?).self) { [weak self] group in
            guard let self else { return }
            
            for (index, notification) in self.notifications.enumerated() {
                guard let postID = notification.postId else { continue }
                
                group.addTask {
                    do {
                        let post = try await self.postService.fetchPost(with: postID)
                        return (index, post)
                    } catch {
                        print("DEBUG: Failed to fetch post with error: \(error)")
                        print("DEBUG: Post id \(postID)")
                        return (index, nil)
                    }
                }
            }
            
            for try await (index, post) in group {
                updatedNotifications[index].post = post
                updatedNotifications[index].post?.author = try await userService.fetchCurrentUser()
            }
        }
        
        self.notifications = updatedNotifications
    }
}
