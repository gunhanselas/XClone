//
//  GoogleAuthError.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Foundation

enum GoogleAuthError: Error {
    case invalidClientID
    case noRootViewController
    case invalidToken
    case invalidProfileData
}
