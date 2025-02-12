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
    @Environment(ProfileViewModel.self) private var viewModel
    
    @State private var isShowingEditProfile = false
    
    let user: User
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                if let headerImageUrl = user.profileHeaderImageUrl {
                    KFImage(URL(string: headerImageUrl))
                        .resizable()
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
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(.white, .black.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Button { dismiss() } label: {
                        Image(systemName: "gear.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(.white, .black.opacity(0.4))
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
                    
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        
                        Text("Joined \(user.createdAt.monthAndYearString())")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                    
                    HStack {
                        Text("\(user.followStats.followingCount)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.primaryText)
                        + Text(" Following")
                        
                        Text("\(user.followStats.followersCount)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.primaryText)
                        + Text(" Followers")
                    }
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                }
                .offset(y: -(AvatarSize.medium.dimension / 2))
                
                Spacer()
                
                XButton(primaryButtonTitle) {
                    primaryButtonTapped()
                }
                .buttonStyle(.standard(rank: primaryButtonRank, size: .compact))
            }
            .padding(.horizontal, 8)
        }
        .fullScreenCover(isPresented: $isShowingEditProfile) {
            EditProfileView(user: user)
        }
    }
}

private extension ProfileHeaderView {
    
    func primaryButtonTapped() {
        switch user.userRelationState {
        case .unknown:
            break
        case .isCurrentUser:
            isShowingEditProfile.toggle()
        case .notFollowed:
            Task { await viewModel.follow() }
        case .followed:
            Task { await viewModel.unfollow() }
        case .blocked:
            print("DEBUG: Unblock user here..")
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
                likeService: MockLikePostService(),
                followService: MockFollowService(),
                userService: MockUserService()
            )
        )
}
