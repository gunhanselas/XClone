//
//  XAppleAuthUser.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Foundation

struct XAppleAuthUser: BaseUser {
    let id: String
    let email: String?
    let fullName: String?
    let isNewUser: Bool
    var fullname: String?
    var username: String = ""
}
