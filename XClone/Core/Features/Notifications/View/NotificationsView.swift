//
//  NotificationsView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingState {
                case .loading:
                    ProgressView()
                        .containerRelativeFrame(.vertical)
                case .empty:
                    Text("Empty state..")
                case .error:
                    Text("An error ocurred.")
                case .complete:
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRowView(notification: notification)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.fetchNotifications() }
    }
}

#Preview {
    NotificationsView()
}
