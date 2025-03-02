//
//  MainTabView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/23/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var snackbarNotificationManager = SnackbarNotificationManager()
    @State private var blockingManager = BlockingManager(service: BlockUserService())
    @State private var isShowingSnackbar = false
    @State private var selection = 0
    @State private var notificationsViewModel = NotificationsViewModel()
    
    @StateObject private var inboxViewModel = InboxViewModel()

    let currentUser: User
    
    var body: some View {
        TabView(selection: $selection) {
            FeedView()
                .tabItem {
                    Image(systemName: "house")
                        .environment(\.symbolVariants, selection == 0 ? .fill : .none)
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(1)
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                        .environment(\.symbolVariants, selection == 2 ? .fill : .none)
                }
                .badge(notificationsViewModel.unreadNotificationsCount)
                .tag(2)
            
            InboxView()
                .tabItem {
                    Image(systemName: "envelope")
                        .environment(\.symbolVariants, selection == 3 ? .fill : .none)
                }
                .badge(inboxViewModel.unreadMessageCount)
                .environmentObject(inboxViewModel)
                .tag(3)
            
            CurrentUserProfileView(currentUser: currentUser)
                .tabItem {
                    Image(systemName: "person")
                        .environment(\.symbolVariants, selection == 4 ? .fill : .none)
                }
                .tag(4)
        }
        .snackbar(message: snackbarNotificationManager.notification?.title ?? "", show: $isShowingSnackbar)
        .onChange(of: snackbarNotificationManager.notification) { _, newValue in
            isShowingSnackbar = newValue != nil
        }
        .environment(blockingManager)
        .environment(notificationsViewModel)
        .environment(snackbarNotificationManager)
    }
}

#Preview {
    MainTabView(currentUser: MockData.currentUser)
}
