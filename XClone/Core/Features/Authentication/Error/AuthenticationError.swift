//
//  AuthenticationError.swift
//  XClone
//
//  Created by Stephan Dowless on 1/25/25.
//

import Foundation

enum AuthenticationError: Error {
    case userDisabled
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case userNotFound
    case networkError
    case credentialAlreadyInUse
    case weakPassword
    case unknown
    case invalidCredential
    case tooManyRequests

    init(rawValue: Int?) {
        switch rawValue {
        case 17004: self = .invalidCredential
        case 17005: self = .userDisabled
        case 17007: self = .emailAlreadyInUse
        case 17008: self = .invalidEmail
        case 17009: self = .wrongPassword
        case 17010: self = .tooManyRequests
        case 17011: self = .userNotFound
        case 17020: self = .networkError
        case 17025: self = .credentialAlreadyInUse
        case 17026: self = .weakPassword
        default: self = .unknown
        }
    }
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "The credentials you entered are invalid. Please try again."
        case .userDisabled:
            return "This account has been disabled."
        case .emailAlreadyInUse:
            return "This email is already in use. Please login or try again."
        case .invalidEmail:
            return "The email address entered is invalid. Please try again."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "There is no account associated with those credentials. Please try again."
        case .networkError:
            return "A network error occurred. Please try again later."
        case .credentialAlreadyInUse:
            return "This credential is already in use. Please try again."
        case .weakPassword:
            return "Password must be at least 6 characters in length. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        case .tooManyRequests:
            return "Access to this account has been temporarily disabled due to multiple failed login attempts. Please try again later."
        }
    }
}
