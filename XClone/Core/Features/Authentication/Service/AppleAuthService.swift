//
//  AppleAuthService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct AppleAuthService {
    func signInWithApple(_ appleIDCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> XAppleAuthUser? {
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("DEBUG: No Apple ID Token found..")
            return nil
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("DEBUG: No ID Token String..")
            return nil
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        let firebaseAuthResult = try await Auth.auth().signIn(with: credential)
        let isNewUser = firebaseAuthResult.additionalUserInfo?.isNewUser ?? false
        
        guard let email = appleIDCredential.email else { return nil }
        var name: String?
        
        if let nameComponents = appleIDCredential.fullName {
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .medium
            name = formatter.string(from: nameComponents)
        }
        
        return XAppleAuthUser(
            id: firebaseAuthResult.user.uid,
            email: email,
            fullName: name,
            isNewUser: isNewUser
        )
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
