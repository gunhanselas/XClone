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
    
    func updateUsername(_ username: String) async throws
    func updateProfilePhoto(_ imageData: Data) async throws -> String
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws
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
    
    func updateUsername(_ username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants.UserCollection.document(uid).updateData(["username": username])
    }
    
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthenticationError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profilePhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileImageUrl": imageUrl])
        return imageUrl
    }
    
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthenticationError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profileHeaderPhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileHeaderImageUrl": imageUrl])
        return imageUrl
    }
    
    func saveUserDataAfterAuthentication(_ baseUser: any BaseUser) async throws {
        let user = User(
            id: baseUser.id,
            username: baseUser.username,
            email: baseUser.email,
            isPrivate: false,
            createdAt: Date()
        )
        
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
