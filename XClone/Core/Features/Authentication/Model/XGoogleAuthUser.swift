//
//  XGoogleAuthUser.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Foundation
import GoogleSignIn

struct XGoogleAuthUser: BaseUser {
    let id: String
    let isNewUser: Bool
    let userProfileData: GIDProfileData
    
    var username: String { "" }
    var email: String { userProfileData.email }
    var fullname: String? { userProfileData.name }
}
