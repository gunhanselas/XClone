//
//  AddProfileHeaderImageView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import PhotosUI
import SwiftUI

struct ProfileHeaderImageSelectorView: View {
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var headerImage: Image?
    @State private var showPhotosPicker = false
    
    var body: some View {
        VStack(spacing: 36) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pick a header")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("People who visit your profile will see it. Show your style.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack(alignment: .bottomLeading) {
                VStack {
                    if let headerImage {
                        headerImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .contentShape(.rect)
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 120)
                            .overlay {
                                Button { showPhotosPicker.toggle() } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera")
                                            .imageScale(.large)
                                        
                                        Text("Upload")
                                            .font(.subheadline)
                                    }
                                }
                            }
                    }
                        
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    AvatarView(user: nil, size: .medium)
                        .shadow(color: .primary.opacity(0.25), radius: 8)
                    
                    Text("Bruce Wayne")
                        .font(.headline)
                    
                    Text("@batman")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 360, height: 200)
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray5), lineWidth: 1.0)
            }
            
            Spacer()
            
            VStack(spacing: 24) {
                XButton("Next") {
                    
                }
                .buttonStyle(.standard)
                .disabled(headerImage == nil)
                .opacity(headerImage == nil ? 0.5 : 1.0)
                
                Button("Skip for now") {
                    
                }
                .foregroundStyle(Color(.primaryText))
                .fontWeight(.semibold)
            }
        }
        .task(id: selectedPickerItem) { await loadHeaderImage() }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPickerItem)
        .padding()
    }
}

private extension ProfileHeaderImageSelectorView {
    func loadHeaderImage() async {
        guard let selectedPickerItem else { return }
        
        do {
            guard let data = try await selectedPickerItem.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.headerImage = Image(uiImage: uiImage)
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileHeaderImageSelectorView()
}
