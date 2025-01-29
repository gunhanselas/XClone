//
//  AddProfilePictureView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import PhotosUI
import SwiftUI

struct ProfileImageSelectorView: View {
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
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
                if let profileImage {
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
            
            Text("You can edit this at any time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(8)
            
            Spacer()
            
            VStack(spacing: 24) {
                XButton("Next") {
                    
                }
                .buttonStyle(.standard)
                .disabled(profileImage == nil)
                .opacity(profileImage == nil ? 0.5 : 1.0)
                
                Button("Skip for now") {
                    
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
            self.profileImage = Image(uiImage: uiImage)
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileImageSelectorView()
}
