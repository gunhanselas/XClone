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
            switch viewModel.loadingState {
            case .loading:
                ProgressView()
                    .containerRelativeFrame(.vertical)
            case .empty:
                Text("Empty state..")
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
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
        .task { await viewModel.fetchNotifications() }
    }
}

#Preview {
    NotificationsView()
}
