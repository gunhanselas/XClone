//
//  GoogleAuthService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

enum GoogleAuthError: Error {
    case invalidClientID
    case noRootViewController
    case invalidToken
}

protocol GoogleAuthServiceProtocol {
    func signIn() async throws -> XGoogleAuthUser
}

struct GoogleAuthService: GoogleAuthServiceProtocol {
    func signIn() async throws -> XGoogleAuthUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleAuthError.invalidClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = await scene?.windows.first?.rootViewController else {
            throw GoogleAuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let googleUser = result.user
    
        guard let idToken = googleUser.idToken?.tokenString else {
            throw GoogleAuthError.invalidToken
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)
        
        let firebaseAuthResult = try await Auth.auth().signIn(with: credential)
        let isNewUser = firebaseAuthResult.additionalUserInfo?.isNewUser ?? false
        
        print("DEBUG: New google user sign in \(isNewUser)")

        return XGoogleAuthUser(isNewUser: isNewUser, user: googleUser)
    }
}
