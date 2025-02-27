//
//  EditProfileView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Kingfisher
import PhotosUI
import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    
    @State private var editProfileManager = EditProfileManager(service: EditProfileService(userService: UserService()))
    
    @State private var selectedHeaderPhotosPickerItem: PhotosPickerItem?
    @State private var selectedProfilePhotosPickerItem: PhotosPickerItem?
    @State private var headerUIImage: UIImage?
    @State private var profilePhotoUIImage: UIImage?
    @State private var headerImage: Image?
    @State private var profileImage: Image?
    @State private var fullname = ""
    @State private var bio = ""
    @State private var didEditUserInfo = false
    @State private var isLoading = false
    @State private var showHeaderPhotosPicker = false
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    if let headerImage {
                        headerImage
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .clipped()
                            .contentShape(.rect)
                    } else if let headerImageUrl = user.profileHeaderImageUrl {
                        KFImage(URL(string: headerImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .clipped()
                            .contentShape(.rect)
                    } else {
                        Rectangle()
                            .fill(.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .clipped()
                            .contentShape(.rect)
                    }
                }
                .onTapGesture { showHeaderPhotosPicker.toggle() }
                
                PhotosPicker(selection: $selectedProfilePhotosPickerItem) {
                    if let profileImage {
                        AvatarView(image: profileImage, size: .medium)
                            .shadow(color: .primary.opacity(0.25), radius: 8)
                    } else {
                        AvatarView(user: user, size: .medium)
                            .shadow(color: .primary.opacity(0.25), radius: 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .offset(y: -(AvatarSize.medium.dimension / 2))
                
                Divider()
                
                HStack(spacing: 32) {
                    Text("Name")
                        .frame(width: 48, alignment: .leading)
                        .fontWeight(.semibold)
                    
                    TextField("Enter your name..", text: $fullname)
                }
                .padding(.vertical, 6)
                .font(.subheadline)
                .padding(.horizontal)
                
                Divider()
                
                HStack(spacing: 32) {
                    Text("Bio")
                        .frame(width: 48, alignment: .leading)
                        .fontWeight(.semibold)
                    
                    TextField("Enter your bio..", text: $bio)
                }
                .padding(.vertical, 6)
                .font(.subheadline)
                .padding(.horizontal)
                
                Divider()
                
                Spacer()
            }
            .photosPicker(isPresented: $showHeaderPhotosPicker, selection: $selectedHeaderPhotosPickerItem)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss() 
                    }
                    .foregroundStyle(.primaryText)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    XButton("Save") {
                        onSaveTapped()
                    }
                    .buttonStyle(.standard(rank: .tertiary), isLoading: $isLoading)
                    .disabled(!didEditUserInfo)
                    .opacity(didEditUserInfo ? 1.0 : 0.5)
                }
            }
        }
        .task(id: selectedHeaderPhotosPickerItem) { await loadHeaderImage() }
        .task(id: selectedProfilePhotosPickerItem) { await loadProfileImage() }
        .onChange(of: fullname) { _, newValue in
            didEditUserInfo = newValue != user.fullname
        }
        .onChange(of: bio) { _, newValue in
            didEditUserInfo = newValue != user.bio
        }
        .onAppear { configureUserDataOnAppear() }
    }
}

private extension EditProfileView {
    func configureUserDataOnAppear() {
        fullname = user.fullname ?? ""
        bio = user.bio ?? ""
    }
    
    func onSaveTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            if let headerUIImage {
                guard let imageData = headerUIImage.jpegData(compressionQuality: 0.5) else { return }
                try await editProfileManager.updateUserHeaderImage(userManager: userManager, with: imageData)
            }
            
            if let profilePhotoUIImage {
                guard let imageData = profilePhotoUIImage.jpegData(compressionQuality: 0.25) else { return }
                try await editProfileManager.updateUserProfileImage(userManager: userManager, with: imageData)
            }
            
            if user.fullname != fullname || user.bio != bio {
                await editProfileManager.updateUser(with: fullname, bio: bio, userManager: userManager)
            }
            
            dismiss()
        }
    }
    
    func loadHeaderImage() async {
        do {
            let data = try await loadImageDataFromPhotoItem(selectedHeaderPhotosPickerItem)
            self.headerUIImage = data.0
            self.headerImage = data.1
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
    
    func loadProfileImage() async {
        do {
            let data = try await loadImageDataFromPhotoItem(selectedProfilePhotosPickerItem)
            self.profilePhotoUIImage = data.0
            self.profileImage = data.1
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
    
    func loadImageDataFromPhotoItem(_ item: PhotosPickerItem?) async throws -> (UIImage?, Image?) {
        guard let item else { return (nil, nil) }
        
        guard let data = try await item.loadTransferable(type: Data.self) else { return (nil, nil) }
        guard let uiImage = UIImage(data: data) else { return (nil, nil) }
        let image = Image(uiImage: uiImage)
        
        self.didEditUserInfo = true

        return (uiImage, image)
    }
}

#Preview {
    EditProfileView(user: MockData.currentUser)
}
