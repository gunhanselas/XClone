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
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User
    func deleteAccount() async throws
    func getAuthState() -> AuthenticationState
    func login(withEmail email: String, password: String) async throws -> AuthenticationState
    func sendResetPasswordLink(toEmail email: String) async throws
    func signout()
}

struct AuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return User(id: result.user.uid, username: username, email: email, isPrivate: false, createdAt: Date())
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
}
