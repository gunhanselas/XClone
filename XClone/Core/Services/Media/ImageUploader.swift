//
//  ImageUploader.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Firebase
import FirebaseStorage

enum ImageUploadError: Error {
    case uploadFailed
}

enum ImageUploadType {
    case profilePhoto
    case post
    case profileHeaderPhoto
    
    var storageReferencePath: String {
        switch self {
        case .profilePhoto:
            return "profile_images"
        case .post:
            return "post_images"
        case .profileHeaderPhoto:
            return "profile_header_images"
        }
    }
}

struct ImageUploader {
    func uploadImage(imageData: Data, type: ImageUploadType) async throws -> String {
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(type.storageReferencePath)/\(filename)")
        
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
