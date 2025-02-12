//
//  EditProfileManager.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

@Observable
class EditProfileManager {
    private let service: EditProfileService
    
    init(service: EditProfileService) {
        self.service = service
    }
    
    func updateUserHeaderImage(userManager: UserManager, with imageData: Data) async throws {
        guard let currentUser = userManager.currentUser else { return }
        let imageURL = try await service.updateProfileHeaderImage(for: currentUser, imageData: imageData)
        userManager.updateHeaderPhoto(with: imageURL)
    }
    
    func updateUserProfileImage(userManager: UserManager, with imageData: Data) async throws {
        guard let currentUser = userManager.currentUser else { return }
        let imageURL = try await service.updateProfilePhotoImage(for: currentUser, imageData: imageData)
        userManager.updateProfilePhoto(with: imageURL)
    }
    
    func updateUser(with fullname: String?, bio: String?) async {
        do {
            try await service.updateUser(with: fullname, bio: bio)
        } catch {
            print("DEBUG: Failed to update user info with error: \(error)")
        }
    }
}
