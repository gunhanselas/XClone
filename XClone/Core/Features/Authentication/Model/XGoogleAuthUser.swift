//
//  XGoogleAuthUser.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Foundation
import GoogleSignIn

struct XGoogleAuthUser: Identifiable, Hashable {
    let isNewUser: Bool
    let user: GIDGoogleUser
    
    var id: String { user.accessToken.tokenString }
}
