//
//  PostReplyViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Observation

@Observable
class PostReplyViewModel {
    private let post: Post
    private let service: PostReplyServiceProtocol
    private let notificationService: SendNotificationService
    
    init(
        post: Post,
        service: PostReplyServiceProtocol = PostReplyService(),
        notificationService: SendNotificationService = SendNotificationService()
    ) {
        self.post = post
        self.service = service
        self.notificationService = notificationService
    }
    
    func uploadReply(caption: String) async throws {
        try await service.uploadReply(caption: caption, to: post.parentPostId ?? post.id)
        try await notificationService.sendReplyNotification(post: post)
    }
}
