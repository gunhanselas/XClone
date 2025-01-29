//
//  UserService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User?
    func fetchUser(withUid uid: String) async throws -> User
    
    func uploadUsername(_ username: String) async throws
    func uploadProfilePhoto(_ imageData: Data) async throws -> String
    func uploadProfileHeaderPhoto(_ imageData: Data) async throws -> String
}

struct UserService: UserServiceProtocol {
    private let imageUploader = ImageUploader()
        
    func fetchCurrentUser() async throws -> User? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        return try await FirestoreConstants
            .UserCollection
            .document(uid)
            .getDocument(as: User.self)
    }
    
    func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    func uploadUsername(_ username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants.UserCollection.document(uid).updateData(["username": username])
    }
    
    func uploadProfilePhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthenticationError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profilePhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileImageUrl": imageUrl])
        return imageUrl
    }
    
    func uploadProfileHeaderPhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthenticationError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profileHeaderPhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileHeaderImageUrl": imageUrl])
        return imageUrl
    }
}
