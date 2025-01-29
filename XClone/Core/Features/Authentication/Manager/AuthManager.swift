//
//  AuthManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation
import GoogleSignIn

@Observable
class AuthManager {
    var authState: AuthenticationState = .notDetermined
    var error: AuthenticationError?
    var googleAuthUser: XGoogleAuthUser?
    var googleAuthError: GoogleAuthError?
    
    private let service: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    
    init(service: AuthServiceProtocol, googleAuthService: GoogleAuthServiceProtocol) {
        self.service = service
        self.googleAuthService = googleAuthService
    }
    
    func configureAuthState() {
        self.authState = service.getAuthState()
    }
    
    func updateAuthState(_ state: AuthenticationState) {
        self.authState = state
    }
    
    func login(withEmail email: String, password: String) async {
        do {
            self.authState = try await service.login(withEmail: email, password: password)
        } catch {
            self.error = .unknown
        }
    }
    
    func signUp(withEmail email: String, password: String, username: String, fullname: String) async throws {
        try await service.createUser(withEmail: email, password: password, username: username, fullname: fullname)
    }
    
    func signInWithGoogle() async {
        do {
            self.googleAuthUser = try await googleAuthService.signIn()
            
            if let googleAuthUser, !googleAuthUser.isNewUser {
                updateAuthState(.authenticated)
            }
            
        } catch let error as GoogleAuthError {
            self.googleAuthError = error
        } catch {
            self.error = .unknown
        }
    }
    
    func signOut() {
        service.signout()
        authState = .unauthenticated
    }
    
    func uploadUsername(_ username: String) async throws {
        try await service.uploadUsername(username)
    }
}
