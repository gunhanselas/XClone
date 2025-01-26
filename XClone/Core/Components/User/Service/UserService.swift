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
}

struct UserService: UserServiceProtocol {    
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
}
