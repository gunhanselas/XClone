//
//  SettingsView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    @State private var showBlockedAccounts = false
    
    var body: some View {
        NavigationStack {
            List {
                if let currentUser = userManager.currentUser {
                    Section("Account Info") {
                        SettingsRowView(title: "Username", value: currentUser.username)
                        SettingsRowView(title: "Email", value: currentUser.email)
                        SettingsRowView(title: "Joined", value: currentUser.createdAt.monthAndYearString())
                    }
                }
                
                Section("Privacy") {
                    Button { showBlockedAccounts.toggle() } label: {
                        HStack {
                            Text("Blocked Accounts")
                                .foregroundStyle(.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                Section {
                    Button("Log Out", role: .destructive) {
                        authManager.signOut()
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        // delete account
                    }
                }
            }
            .navigationDestination(isPresented: $showBlockedAccounts) {
                UserListView(config: .blockedAccounts)
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
}

struct SettingsRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
        .environment(UserManager(service: MockUserService()))
}
