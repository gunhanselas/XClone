//
//  ProfileHeaderImageView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Kingfisher
import SwiftUI

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack {
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
                        
                        Text("Joined January 2025")
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
                
                Button("Set up profile") {
                    
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    ProfileHeaderView(user: MockData.currentUser)
}
