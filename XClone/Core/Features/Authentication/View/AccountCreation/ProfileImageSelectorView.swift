//
//  AddProfilePictureView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import PhotosUI
import SwiftUI

struct ProfileImageSelectorView: View {
    @Environment(AuthenticationRouter.self) private var router
    @Environment(UserManager.self) private var userManager
    @EnvironmentObject private var store: AuthDataStore
    
    @State private var isUploadingPhoto = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var uiImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pick a profile picture")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Have a favorite selfie? Upload it now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            PhotosPicker(selection: $selectedPickerItem) {
                if let profileImage = store.profileImage {
                    AvatarView(image: profileImage, size: .custom(200))
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        AvatarView(user: nil, size: .custom(200))
                        
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color(.primaryTextInverse), .blue)
                            .offset(x: -4, y: -4)
                    }
                }
            }
            
            Text("You can always change it later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(8)
            
            Spacer()
            
            VStack(spacing: 24) {
                XButton("Next") {
                    uploadProfilePhoto()
                }
                .buttonStyle(.standard, isLoading: $isUploadingPhoto)
                .disabled(store.profileImage == nil)
                .opacity(store.profileImage == nil ? 0.5 : 1.0)
                
                Button("Skip for now") {
                    router.pushNextAccountCreationStep()
                }
                .foregroundStyle(Color(.primaryText))
                .fontWeight(.semibold)
            }
        }
        .padding()
        .task(id: selectedPickerItem) {
            await loadProfilePhoto()
        }
    }
}

private extension ProfileImageSelectorView {
    func loadProfilePhoto() async {
        guard let selectedPickerItem else { return }
        
        do {
            guard let data = try await selectedPickerItem.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            
            self.uiImage = uiImage
            store.profileImage = Image(uiImage: uiImage)
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
    
    func uploadProfilePhoto() {
        Task {
            isUploadingPhoto = true
            defer { isUploadingPhoto = false }
            
            do {
                guard let imageData = uiImage?.jpegData(compressionQuality: 0.5) else { return }
                try await userManager.uploadProfilePhoto(with: imageData)
                router.pushNextAccountCreationStep()
            } catch {
                print("DEBUG: Failed to upload image with error: \(error)")
            }
        }
    }
}

#Preview {
    ProfileImageSelectorView()
}
