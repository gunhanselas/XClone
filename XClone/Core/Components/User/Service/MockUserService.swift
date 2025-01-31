//
//  MockUserService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Foundation

class MockUserService: UserServiceProtocol {
    var currentUser = MockData.currentUser
    
    func fetchCurrentUser() async throws -> User? {
        return currentUser
    }
    
    func fetchUser(withUid uid: String) async throws -> User {
        return MockData.users.first(where: { $0.id == uid }) ?? currentUser
    }
    
    func updateUsername(_ username: String) async throws {
        currentUser.username = username
    }
    
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        return UUID().uuidString
    }
    
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String {
        return UUID().uuidString
    }
    
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws {
        
    }
}
