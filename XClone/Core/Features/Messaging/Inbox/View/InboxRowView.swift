//
//  InboxRowView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/10/25.
//

import SwiftUI

struct InboxRowView: View {
    @Environment(UserManager.self) private var userManager
    @EnvironmentObject private var viewModel: InboxViewModel
    
    let thread: Thread
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(showUnreadIndicator ? .blue : .clear)
            
            if let threadIndex {
                AvatarView(user: viewModel.threads[threadIndex].lastMessage?.user, size: .small)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let threadIndex {
                        Text(viewModel.threads[threadIndex].lastMessage?.user?.username ?? "Loading..")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
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
        .frame(height: 48)
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
        guard let currentUser = userManager.currentUser else { return false }
        guard let lastMessage = thread.lastMessage, !lastMessage.isMessageFromCurrentUser(currentUid: currentUser.id) else { return false }
        return lastMessage.status == .delivered
    }
    
    var subtitle: String {
        guard let currentUser = userManager.currentUser else { return "" }

        if let lastMessage = thread.lastMessage {
            return lastMessage.isMessageFromCurrentUser(currentUid: currentUser.id)
            ? "You: \(lastMessage.messageText)"
            : lastMessage.messageText
        }
        
        return ""
    }
    
    var threadIndex: Int? {
        return viewModel.threads.firstIndex(where: { $0.id == thread.id })
    }
}
