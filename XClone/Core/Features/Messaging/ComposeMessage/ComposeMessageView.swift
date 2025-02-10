//
//  ComposeMessageView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/10/25.
//

import SwiftUI

struct ComposeMessageView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedUser: User?
    
    var body: some View {
        NavigationStack {
            UserListView(config: .newMessage, selectedUser: $selectedUser)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundStyle(Color(.primaryText))
                    }
                }
        }
        .onAppear { selectedUser = nil }
    }
}

#Preview {
    ComposeMessageView(selectedUser: .constant(nil))
}
