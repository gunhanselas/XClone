//
//  RegistrationValidationError.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

enum RegistrationValidationError: Error {
    case emailValidationFailed
    case usernameValidationFailed
    case invalidUsernameFormat
    case invalidEmailFormat
    case unknown
    case networkError
}

extension RegistrationValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emailValidationFailed:
            "This email is already in use. Please login or try again."
        case .usernameValidationFailed:
            "This username is already in use. Please try again."
        case .invalidUsernameFormat:
            "Username format is invalid. Please try again."
        case .invalidEmailFormat:
            "Email entered is invalid. Please try again."
        case .unknown:
            "An unknown error occurred. Please try again."
        case .networkError:
            "A network error occurred. Please try again."
        }
    }
}
