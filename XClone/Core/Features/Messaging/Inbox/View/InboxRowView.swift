//
//  InboxRowView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/10/25.
//

import SwiftUI

struct InboxRowView: View {
    @Environment(InboxViewModel.self) private var viewModel
    
    let thread: Thread
    
    var body: some View {
        HStack(spacing: 12) {
            if showUnreadIndicator {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.blue)
            }
            
            AvatarView(user: thread.lastMessage?.user, size: .medium)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.lastMessage?.user?.username ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    HStack {
                        Text(thread.lastUpdated.timestampString())
                        
                        Image(systemName: "chevron.right")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
            }
        }
        .frame(maxHeight: 72)
        .swipeActions {
            withAnimation(.spring()) {
                Button { onDelete() } label: {
                    Image(systemName: "trash")
                }
                .tint(Color(.systemRed))
            }
        }
    }
}

private extension InboxRowView {
    func onDelete() {
        Task { await viewModel.deleteThread(thread) }
    }
    
    var showUnreadIndicator: Bool {
        guard let lastMessage = thread.lastMessage, !lastMessage.isFromCurrentUser else { return false }
        return lastMessage.status == .delivered
    }
    
    var subtitle: String {
        if let lastMessage = thread.lastMessage {
            return lastMessage.isFromCurrentUser ? "You: \(lastMessage.messageText)" : lastMessage.messageText
        }
        
        return ""
    }
}
