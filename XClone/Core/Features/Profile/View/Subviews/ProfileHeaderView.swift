//
//  ProfileHeaderImageView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Kingfisher
import SwiftUI

struct ProfileHeaderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    
    @Environment(BlockingManager.self) private var blockingManager
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(SnackbarNotificationManager.self) private var snackbarManager
    @Environment(UserManager.self) private var userManager
        
    @State private var isShowingBlockAlert = false
    @State private var isShowingReportView = false
    @State private var showPrimaryButtonLoadingIndicator = false
    @State private var sheetConfig: ProfileHeaderView.SheetConfiguration?
    
    let user: User
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                if let headerImageUrl = user.profileHeaderImageUrl {
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
                
                HStack {
                    if isPresented {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white, .black.opacity(0.4))
                        }
                    }
                    
                    Spacer()
                    
                    if user.userRelationState == .isCurrentUser {
                        Button { sheetConfig = .settings } label: {
                            Image(systemName: "gear.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white, .black.opacity(0.4))
                        }
                    } else {
                        Menu {
                            Button("Report @\(user.username)", action: { isShowingReportView.toggle() })
                            Button("Block @\(user.username)", action: { isShowingBlockAlert.toggle() })

                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white, .black.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    AvatarView(user: user, size: .medium)
                        .shadow(color: .primary.opacity(0.25), radius: 8)
                    
                    if let fullname = user.fullname {
                        Text(fullname)
                            .font(.headline)
                    }
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let bio = user.bio {
                        Text(bio)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        
                        Text("Joined \(user.createdAt.monthAndYearString())")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                    
                    HStack {
                        NavigationLink(value: UserListConfiguration.following(uid: user.id)) {
                            Text("\(user.followStats.followingCount)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primaryText)
                            + Text(" Following")
                        }
                        .disabled(user.followStats.followingCount == 0)
                        
                        NavigationLink(value: UserListConfiguration.followers(uid: user.id)) {
                            Text("\(user.followStats.followersCount)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primaryText)
                            + Text(" Followers")
                        }
                        .disabled(user.followStats.followersCount == 0)
                    }
                    .foregroundStyle(.gray)
                    .font(.footnote)
                }
                .offset(y: -(AvatarSize.medium.dimension / 2))
                
                Spacer()
                
                XButton(primaryButtonTitle) {
                    primaryButtonTapped()
                }
                .buttonStyle(
                    .standard( rank: primaryButtonRank, size: .compact),
                    isLoading: $showPrimaryButtonLoadingIndicator
                )
            }
            .padding(.horizontal, 8)
        }
        .blockAlert(user: user, isShowing: $isShowingBlockAlert, onBlock: onBlock)
        .sheet(isPresented: $isShowingReportView) {
            ReportContentView(contentType: .account(user: user))
        }
        .fullScreenCover(item: $sheetConfig) { config in
            switch config {
            case .editProfile:
                EditProfileView(user: user)
                    .onDisappear {
                        guard let currentUser = userManager.currentUser else { return }
                        viewModel.user = currentUser
                    }
            case .settings:
                SettingsView()
            }
        }
    }
}

private extension ProfileHeaderView {
    
    enum SheetConfiguration: Identifiable, Hashable {
        case editProfile
        case settings
        
        var id: Int { hashValue }
    }
    
    func primaryButtonTapped() {
        switch user.userRelationState {
        case .unknown:
            break
        case .isCurrentUser:
            sheetConfig = .editProfile
        case .notFollowed:
            Task { await viewModel.follow() }
        case .followed:
            Task { await viewModel.unfollow() }
        case .blocked:
            Task {
                showPrimaryButtonLoadingIndicator = true
                await blockingManager.unblockUser(user)
                viewModel.user.userRelationState = .notFollowed
                showPrimaryButtonLoadingIndicator = false
            }
        }
    }
    
    func onBlock() {
        Task {
            showPrimaryButtonLoadingIndicator = true
            await blockingManager.blockUser(user.id)
            snackbarManager.show(.blocked(user))
            viewModel.user.userRelationState = .blocked
            showPrimaryButtonLoadingIndicator = false
        }
    }
    
    var primaryButtonTitle: String {
        switch user.userRelationState {
        case .unknown:
            "Loading"
        case .isCurrentUser:
            "Edit Profile"
        case .notFollowed:
            "Follow"
        case .followed:
            "Following"
        case .blocked:
            "Unblock"
        }
    }
    
    var primaryButtonRank: XButtonRank {
        switch user.userRelationState {
        case .isCurrentUser, .followed, .blocked, .unknown:
            .secondary
        default:
            .primary
        }
    }
}

#Preview {
    ProfileHeaderView(user: MockData.currentUser)
        .environment(
            ProfileViewModel(
                user: MockData.currentUser,
                profileService: MockProfileService(),
                followService: MockFollowService(),
                userService: MockUserService()
            )
        )
}
