//
//  NotificationsView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel(service: XNotificationService())
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.notifications) { notification in
                        Text(notification.id)
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
