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
    @State private var isShowingLogoutAlert = false
    @State private var isShowingAccountDeletionAlert = false

    var body: some View {
        NavigationStack {
            List {
                if let currentUser = userManager.currentUser {
                    Section("Account Info") {
                        SettingsRowView(title: "Username", value: currentUser.username)
                        
                        if let email = currentUser.email {
                            SettingsRowView(title: "Email", value: email)
                        }
                        
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
                        isShowingLogoutAlert.toggle()
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        isShowingAccountDeletionAlert.toggle()
                    }
                }
            }
            .alert("Delete Account?", isPresented: $isShowingAccountDeletionAlert, actions: {
                Button("Delete Account", role: .destructive) {
                    Task { await authManager.deleteAccount() }
                }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Are you sure you want to delete your account? This operation cannot be undone and all of your data will be permanently deleted.")
            })
            .alert("Log Out?", isPresented: $isShowingLogoutAlert, actions: {
                Button("Log Out", role: .destructive) { authManager.signOut() }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Are you sure you want to log out?")
            })
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

private extension SettingsView {
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
}

#Preview {
    SettingsView()
        .environment(AuthManager())
        .environment(UserManager(service: MockUserService()))
}
