//
//  RegistrationValidationManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Observation

@Observable
class RegistrationValidationManager {
    var emailValidationState: InputValidationState = .idle
    var usernameValidationState: InputValidationState = .idle
    var validationError: RegistrationValidationError?
    
    private let service: RegistrationValidationProtocol
    
    init(service: RegistrationValidationProtocol) {
        self.service = service
    }
    
    func validateEmail(_ email: String) async -> Bool {
        emailValidationState = .validating
        
        do {
            return try await service.validateEmail(email)
        } catch {
            self.validationError = error as? RegistrationValidationError ?? .unknown
            return false
        }
    }
    
    func validateUsername(_ username: String) async -> Bool {
        usernameValidationState = .validating
        
        do {
            return try await service.validateUsername(username)
        } catch {
            self.validationError = error as? RegistrationValidationError ?? .unknown
            return false
        }
    }
}
