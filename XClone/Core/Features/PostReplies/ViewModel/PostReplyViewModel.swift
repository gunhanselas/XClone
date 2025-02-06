//
//  PostReplyViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Observation

@Observable
class PostReplyViewModel {
    private let service: PostReplyServiceProtocol
    
    init(service: PostReplyServiceProtocol) {
        self.service = service
    }
    
    func uploadReply(caption: String) async throws {
        try await service.uploadReply(caption: caption)
    }
}
