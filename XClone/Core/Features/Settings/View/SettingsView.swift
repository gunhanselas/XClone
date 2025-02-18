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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let currentUser = userManager.currentUser {
                        SettingsRowView(title: "Username", value: currentUser.username)
                        SettingsRowView(title: "Email", value: currentUser.email)
                        SettingsRowView(title: "Joined", value: currentUser.createdAt.monthAndYearString())
                    }
                    
                    Button("Log Out", role: .destructive) {
                        authManager.signOut()
                    }
                    .font(.headline)
                }
                .padding()
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
                .fontWeight(.semibold)
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .frame(height: 40)
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
        .environment(UserManager(service: MockUserService()))
}
