//
//  UploadPostViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Foundation
import Observation

@Observable
class UploadPostViewModel {
    var error: Error?
    
    private let service: CreatePostServiceProtocol
    
    init(service: CreatePostServiceProtocol) {
        self.service = service
    }
    
    func uploadPost(caption: String, imageData: Data? = nil) async throws {
        do {
            try await service.uploadPost(caption: caption, imageData: imageData)
        } catch {
            self.error = error
            throw error
        }
    }
}
