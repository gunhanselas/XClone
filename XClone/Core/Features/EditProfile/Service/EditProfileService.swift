//
//  EditProfileService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct EditProfileService {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func updateProfileHeaderImage(for currentUser: User, imageData: Data) async throws -> String {
        if let imageURL = currentUser.profileHeaderImageUrl {
            try await Storage.storage().reference(forURL: imageURL).delete()
        }
        
        return try await userService.updateProfileHeaderPhoto(imageData)
    }
    
    func updateProfilePhotoImage(for currentUser: User, imageData: Data) async throws -> String {
        if let imageURL = currentUser.profileImageUrl {
            try await Storage.storage().reference(forURL: imageURL).delete()
        }
        
        return try await userService.updateProfilePhoto(imageData)
    }
    
    func updateUser(with fullname: String?, bio: String?) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let batch = Firestore.firestore().batch()
        let userRef = FirestoreConstants.UserCollection.document(currentUid)

        if let fullname = fullname {
            batch.updateData(["fullname": fullname], forDocument: userRef)
        }
        
        if let bio = bio, !bio.isEmpty {
            batch.updateData(["bio": bio], forDocument: userRef)
        }
        
        try await batch.commit()
    }
}
