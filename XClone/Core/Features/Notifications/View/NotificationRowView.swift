//
//  NotificationRowView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import SwiftUI

struct NotificationRowView: View {
    let notification: XNotification
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: notificationImageName)
                    .imageScale(.large)
                    .foregroundStyle(notificationImageColor)
                    .offset(y: AvatarSize.small.dimension / 4)
                
                VStack(alignment: .leading) {
                    
                    NavigationLink(value: notification.sender) {
                        AvatarView(user: notification.sender, size: .small)
                    }
                    
                    Text("\(notification.sender?.username ?? "") \(notificationMessage)")
                        .foregroundStyle(.primaryText)
                    
                    if let post = notification.post {
                        Text(post.caption)
                            .foregroundStyle(.gray)
                            .padding(.vertical, 4)
                    }
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            Divider()
        }
    }
}

private extension NotificationRowView {
    var notificationImageName: String {
        switch notification.type {
        case .like:
            "heart.fill"
        case .reply:
            "arrow.right.circle.fill"
        case .repost:
            "repeat.circle.fill"
        case .follow:
            "person.circle.fill"
        }
    }
    
    var notificationImageColor: Color {
        switch notification.type {
        case .like:
            .pink
        case .reply:
            .blue
        case .repost:
            .green
        case .follow:
            .purple
        }
    }
    
    var notificationMessage: String {
        switch notification.type {
        case .like:
            "liked your post"
        case .reply:
            "replied to your post"
        case .repost:
            "reposted your post"
        case .follow:
            "started following you"
        }
    }
}

#Preview {
    NotificationRowView(notification: MockData.notification)
}
