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
        if isNewUser {
            try await uploadUserData(googleUser, uid: firebaseAuthResult.user.uid)
        }
        
        return XGoogleAuthUser(isNewUser: isNewUser, user: googleUser)
    }
    
    private func uploadUserData(_ googleUser: GIDGoogleUser, uid: String) async throws {
        guard let profileData = googleUser.profile else { throw GoogleAuthError.invalidProfileData }
        
        let user = User(
            id: uid,
            username: "",
            fullname: profileData.name,
            email: profileData.email,
            isPrivate: false,
            createdAt: Date()
        )
        
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
