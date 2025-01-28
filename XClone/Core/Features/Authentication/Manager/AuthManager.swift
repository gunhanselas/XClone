//
//  AuthManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

@Observable
class AuthManager {
    var authState: AuthenticationState = .notDetermined
    var error: AuthenticationError?
    var googleAuthError: GoogleAuthError?
    
    private let service: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    
    init(service: AuthServiceProtocol, googleAuthService: GoogleAuthServiceProtocol) {
        self.service = service
        self.googleAuthService = googleAuthService
    }
    
    func configureAuthState() {
        self.authState = service.getAuthState()
        print("DEBUG: Auth state \(authState)")
    }
    
    func login(withEmail email: String, password: String) async {
        do {
            self.authState = try await service.login(withEmail: email, password: password)
        } catch {
            self.error = .unknown
        }
    }
    
    func signInWithGoogle() async {
        do {
            self.authState = try await googleAuthService.signIn()
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
}
