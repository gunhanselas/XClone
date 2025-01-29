//
//  AuthService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/25/25.
//

import Foundation
import FirebaseAuth
import Firebase

protocol AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws
    func deleteAccount() async throws
    func getAuthState() -> AuthenticationState
    func login(withEmail email: String, password: String) async throws -> AuthenticationState
    func sendResetPasswordLink(toEmail email: String) async throws
    func signout()
    func uploadUsername(_ username: String) async throws
}

struct AuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await uploadUserData(uid: result.user.uid, username: username, email: email, fullname: fullname)
        } catch {
            let authErrorCode = AuthErrorCode(_bridgedNSError: error as NSError)?.rawValue
            throw AuthenticationError(rawValue: authErrorCode)
        }
    }
    
    func deleteAccount() async throws {
        
    }
    
    func getAuthState() -> AuthenticationState {
        return Auth.auth().currentUser?.uid == nil ? .unauthenticated : .authenticated
    }
    
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return .authenticated
        } catch {
            let authErrorCode = AuthErrorCode(_bridgedNSError: error as NSError)?.rawValue
            throw AuthenticationError(rawValue: authErrorCode)
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        
    }
    
    func signout() {
        try? Auth.auth().signOut()
    }
    
    func uploadUsername(_ username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants.UserCollection.document(uid).updateData(["username": username])
    }
    
    private func uploadUserData(uid: String, username: String, email: String, fullname: String) async throws {
        let user = User(
            id: uid,
            username: username,
            fullname: fullname, email: email,
            isPrivate: false,
            createdAt: Date()
        )
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
