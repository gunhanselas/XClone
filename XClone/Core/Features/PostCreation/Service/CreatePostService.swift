//
//  CreatePostService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol CreatePostServiceProtocol {
    func uploadPost(caption: String, dataRepresentation: PostMediaDataRepresentation?) async throws
}

enum PostMediaDataRepresentation {
    case photo(Data)
    case video(URL)
}

struct CreatePostService: CreatePostServiceProtocol {
    func uploadPost(caption: String, dataRepresentation: PostMediaDataRepresentation?) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postRef = FirestoreConstants.PostsCollection.document()
        
        var post = Post(
            id: postRef.documentID,
            authorID: currentUid,
            timestamp: Date(),
            caption: caption,
            engagement: PostEngagement()
        )
        
        switch dataRepresentation {
        case .photo(let data):
            post.imageURL = try await ImageUploader().uploadImage(imageData: data, type: .post)
        case .video(let url):
            post.videoURL = try await VideoService().uploadVideoToStorage(withUrl: url)
        case nil:
            break
        }
        
        let data = try Firestore.Encoder().encode(post)
        try await postRef.setData(data)
    }
}
