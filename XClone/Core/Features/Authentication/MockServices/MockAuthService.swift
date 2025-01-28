//
//  MockAuthService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/28/25.
//

import Foundation

struct MockAuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String) async throws -> AuthenticationState {
        try await Task.sleep(for: .seconds(1))
        return .authenticated
    }
    
    func deleteAccount() async throws {
        
    }
    
    func getAuthState() -> AuthenticationState {
        return .authenticated
    }
    
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        try await Task.sleep(for: .seconds(1))
        return .authenticated
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        
    }
    
    func signout() {
        
    }
}

struct MockGoogleAuthService: GoogleAuthServiceProtocol {
    func signIn() async throws -> AuthenticationState {
        try await Task.sleep(for: .seconds(1))
        return .authenticated
    }
}
