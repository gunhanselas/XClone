//
//  UserManager.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import FirebaseStorage
import Foundation

@Observable
class UserManager {
    var currentUser: User?
    
    private let service: UserServiceProtocol
    
    init(service: UserServiceProtocol) {
        self.service = service
    }
    
    func fetchCurrentUser() async {
        do {
            self.currentUser = try await service.fetchCurrentUser()
            self.currentUser?.userRelationState = .isCurrentUser
        } catch {
            print("DEBUG: Error fetching current user: \(error)")
        }
    }
    
    func updateProfilePhoto(with imageURL: String) {
        self.currentUser?.profileImageUrl = imageURL
    }
    
    func updateHeaderPhoto(with imageURL: String) {
        self.currentUser?.profileHeaderImageUrl = imageURL
    }
    
    func uploadUsername(_ username: String) async throws {
        try await service.updateUsername(username)
        self.currentUser?.username = username
    }
    
    func uploadProfilePhoto(with imageData: Data) async throws {
        let imageURL = try await service.updateProfilePhoto(imageData)
        updateProfilePhoto(with: imageURL)
    }
    
    func uploadProfileHeaderPhoto(with imageData: Data) async throws {
        let imageURL = try await service.updateProfileHeaderPhoto(imageData)
        updateHeaderPhoto(with: imageURL)
    }
    
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async {
        do {
            try await service.saveUserDataAfterAuthentication(user)
        } catch {
            print("DEBUG: Failed to save user data to firestore with error: \(error)")
        }
    }
}
