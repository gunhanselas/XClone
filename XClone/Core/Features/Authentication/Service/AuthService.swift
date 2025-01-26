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
    func createUser(withEmail email: String, password: String, username: String) async throws -> String
    func deleteAccount() async throws
    func getUserSession() -> String?
    func login(withEmail email: String, password: String) async throws -> String
    func sendResetPasswordLink(toEmail email: String) async throws
    func signout()
}

struct AuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            await uploadUserData(uid: result.user.uid, username: username, email: email)
            return result.user.uid
        } catch {
            let authErrorCode = AuthErrorCode(_bridgedNSError: error as NSError)?.rawValue
            throw AuthenticationError(rawValue: authErrorCode)
        }
    }
    
    func deleteAccount() async throws {
        
    }
    
    func getUserSession() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func login(withEmail email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
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
    
    private func uploadUserData(uid: String, username: String, email: String) async {
//        let user = User(id: uid, username: username, email: email, isPrivate: false)
//        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
//        try? await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
