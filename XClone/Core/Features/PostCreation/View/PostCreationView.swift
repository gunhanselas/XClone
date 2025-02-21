//
//  UploadPostView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import PhotosUI
import SwiftUI

struct PostCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    @Environment(SnackbarNotificationManager.self) private var snackbarManager

    @FocusState var isFocused: Bool

    @State private var caption = ""
    @State private var isShowingCancellationAlert = false
    @State private var isShowingPhotosPicker = false
    @State private var isUploading = false
    @State private var postImage: Image?
    @State private var postUIImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @State private var viewModel = UploadPostViewModel(service: CreatePostService())
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 16) {
                    AvatarView(user: userManager.currentUser, size: .small)
                    
                    TextField("What's happening?", text: $caption, axis: .vertical)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                }
                .padding()
                
                if let postImage {
                    postImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 320, height: 300)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                Spacer()
                
                if postImage == nil {
                    VStack {
                        Divider()
                        
                        HStack(spacing: 16) {
                            Button { isShowingPhotosPicker.toggle() } label: {
                                Image(systemName: "photo")
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                    }
                }
            }
            .alert("Cancel?", isPresented: $isShowingCancellationAlert, actions: {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                
                Button("Continue", role: .cancel) {}
            }, message: {
                Text("Are you sure you want to discard this post?")
            })
            .task(id: selectedPhotoItem) {
                await loadPostImage()
            }
            .photosPicker(isPresented: $isShowingPhotosPicker, selection: $selectedPhotoItem)
            .onAppear { isFocused = true }
            .toolbar {
                cancelButton
                postButton
            }
        }
    }
}

private extension PostCreationView {
    func loadPostImage() async {
        guard let selectedPhotoItem else { return }
        
        do {
            guard let data = try await selectedPhotoItem.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            
            self.postUIImage = uiImage
            self.postImage = Image(uiImage: uiImage)
        } catch {
            print("DEBUG: Failed to select profile photo with error: \(error.localizedDescription)")
        }
    }
    
    func onUploadTapped() {
        Task {
            isUploading = true
            defer { isUploading = false }
            
            let imageData = postUIImage?.jpegData(compressionQuality: 0.5)
            try await viewModel.uploadPost(caption: caption, imageData: imageData)
            
            snackbarManager.show(.postUploaded)
            dismiss()
        }
    }
}

private extension PostCreationView {
    @ToolbarContentBuilder
    var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                isShowingCancellationAlert.toggle()
            }
        }
    }
    
    @ToolbarContentBuilder
    var postButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            XButton("Post") {
                onUploadTapped()
            }
            .buttonStyle(.standard(size: .compact, variant: .primary), isLoading: $isUploading)
            .disabled(caption.isEmpty)
            .opacity(caption.isEmpty ? 0.5 : 1.0)
        }
    }
}

#Preview {
    PostCreationView()
}
