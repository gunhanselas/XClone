//
//  RegistrationValidationService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

protocol RegistrationValidationProtocol {
    func validateEmail(_ email: String) async throws -> Bool
    func validateUsername(_ username: String) async throws -> Bool
}

struct RegistrationValidationService: RegistrationValidationProtocol {
    func validateEmail(_ email: String) async throws -> Bool {
        let isValid = try await checkUniqueness(forKey: "email", value: email)
        guard isValid else { throw RegistrationValidationError.emailValidationFailed }
        
        return isValid
    }
    
    func validateUsername(_ username: String) async throws -> Bool {
        let isValid = try await checkUniqueness(forKey: "username", value: username)
        guard isValid else { throw RegistrationValidationError.usernameValidationFailed }
        
        return isValid
    }
    
    private func checkUniqueness(forKey key: String, value: String) async throws -> Bool {
        let snapshot = try await FirestoreConstants
            .UserCollection
            .whereField(key, isEqualTo: value)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.isEmpty
    }
}

class MockRegistrationValidationService: RegistrationValidationProtocol {
    func validateEmail(_ email: String) async throws -> Bool {
        return email.isValidEmail()
    }
    
    func validateUsername(_ username: String) async throws -> Bool {
        return username.isValidUsername()
    }
}
