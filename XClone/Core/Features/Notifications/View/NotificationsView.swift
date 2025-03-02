//
//  NotificationsView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(NotificationsViewModel.self) private var viewModel
        
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingState {
                case .loading:
                    ProgressView()
                        .containerRelativeFrame(.vertical)
                case .empty:
                    ContentUnavailableView(
                        "No notifications yet.",
                        systemImage: "bell.slash",
                        description: Text("Notifications will appear here when users interact with you.")
                    )
                case .error:
                    Text("An error ocurred.")
                case .complete:
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.notifications) { notification in
                                NavigationLink(value: notification) {
                                    NotificationRowView(notification: notification)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: XNotification.self) { notification in
                if let post = notification.post {
                    PostDetailView(post: post, viewModel: viewModel)
                } else if let sender = notification.sender {
                    UserProfileView(user: sender)
                }
            }
            .navigationDestination(for: User.self) { user in
                UserProfileView(user: user)
            }
        }
        .task(id: viewModel.notifications) {
            guard !viewModel.notifications.isEmpty, viewModel.unreadNotificationsCount > 0 else { return }
            await viewModel.updateNotifcationsAsRead()
        }
        .refreshable { await viewModel.refreshNotifications() }
    }
}

#Preview {
    NotificationsView()
}
