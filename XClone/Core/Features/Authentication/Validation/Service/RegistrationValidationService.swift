//
//  RegistrationValidationService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

protocol RegistrationValidationProtocol {
    func validateEmail(_ email: String) async throws -> InputValidationState
    func validateUsername(_ username: String) async throws -> InputValidationState
}

struct RegistrationValidationService: RegistrationValidationProtocol {
    func validateEmail(_ email: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "email", value: email)
        guard isValid else { throw RegistrationValidationError.emailValidationFailed }
        
        return isValid ? .validated : .invalid
    }
    
    func validateUsername(_ username: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "username", value: username)
        guard isValid else { throw RegistrationValidationError.usernameValidationFailed }
        
        return isValid ? .validated : .invalid
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
    func validateEmail(_ email: String) async throws -> InputValidationState {
        return email.isValidEmail() ? .validated : .invalid
    }
    
    func validateUsername(_ username: String) async throws -> InputValidationState {
        return username.isValidUsername() ? .validated : .invalid
    }
}
