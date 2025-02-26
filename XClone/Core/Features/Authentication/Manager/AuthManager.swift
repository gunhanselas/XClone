//
//  AuthManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import AuthenticationServices
import Foundation
import GoogleSignIn

@Observable
class AuthManager: NSObject {
    var authState: AuthenticationState = .notDetermined
    var error: AuthenticationError?
    
    var appleAuthUser: XAppleAuthUser?
    var googleAuthUser: XGoogleAuthUser?
    var googleAuthError: GoogleAuthError?
    
    private let service: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    private let appleAuthService: AppleAuthService
    
    private var currentNOnce: String?
    
    init(
        service: AuthServiceProtocol = AuthService(),
        googleAuthService: GoogleAuthServiceProtocol = GoogleAuthService(),
        appleAuthService: AppleAuthService = AppleAuthService()
    ) {
        self.service = service
        self.googleAuthService = googleAuthService
        self.appleAuthService = appleAuthService
    }
    
    func configureAuthState() {
        self.authState = service.getAuthState()
    }
    
    func deleteAccount() async {
        do {
            try await service.deleteAccount()
            signOut()
        } catch {
            print("DEBUG: Failed to delete account with error: \(error)")
        }
    }
    
    func login(withEmail email: String, password: String) async {
        do {
            self.authState = try await service.login(withEmail: email, password: password)
        } catch {
            self.error = .unknown
            print("DEBUG: Failed to login with error: \(error)")
        }
    }
    
    func signUp(withEmail email: String, password: String, username: String, fullname: String) async throws -> User {
        return try await service.createUser(
                withEmail: email,
                password: password,
                username: username,
                fullname: fullname
            )
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
    
    func updateAuthState(_ state: AuthenticationState) {
        self.authState = state
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func requestAppleAuthorization() {
        let nonce = appleAuthService.randomNonceString()
        self.currentNOnce = nonce
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = appleAuthService.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            guard let appleAuthUser = try await appleAuthService.signInWithApple(appleIDCredential, nonce: currentNOnce) else { return }
            
            if appleAuthUser.isNewUser {
                print("DEBUG: Is new user")
                self.appleAuthUser = appleAuthUser
            } else {
                print("DEBUG: Is not new user")
                updateAuthState(.authenticated)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("DEBUG: Failed with error: \(error)")
    }
}
