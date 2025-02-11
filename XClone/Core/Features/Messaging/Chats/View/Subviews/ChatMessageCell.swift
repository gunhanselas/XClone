//
//  ChatMessageCell.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI
import Firebase
import Kingfisher

struct ChatMessageCell: View {
    @Environment(UserManager.self) private var userManager
    @Environment(ChatViewModel.self) private var viewModel
    
    private let message: ChatMessage
    
    init(message: ChatMessage) {
        self.message = message
    }
    
    var body: some View {
        VStack {
            if shouldShowMessageTimestampGroupingLabel {
                Text(timestampString)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 4)
                    .padding(.vertical, 6)
            }
            HStack {
                if isMessageFromCurrentUser {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(message.messageText)
                            .modifier(ChatBubbleModifier(isFromCurrentUser: true))
                        
                        if shouldShowMessageStatusLabel, let messageIndex {
                            Text(viewModel.messages[messageIndex].status.description)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.trailing, 14)
                        }
                    }
                } else {
                    HStack(alignment: .bottom, spacing: 6) {
                        if shouldShowMessageAvatarView {
                            AvatarView(user: message.user, size: .xSmall)
                                .padding(.leading, 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if shouldShowUsername, let user = message.user {
                                Text(user.username)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 8)
                            }
                            
                            Text(message.messageText)
                                .modifier(ChatBubbleModifier(isFromCurrentUser: false))
                        }
                    }
                    .padding(.leading, leadingPadding)
                    .padding(.bottom, bottomPadding)
                    
                    Spacer()
                }
            }
        }
    }
}

private extension ChatMessageCell {
    var isMessageFromCurrentUser: Bool {
        guard let currentUser = userManager.currentUser else { return false }
        return message.isMessageFromCurrentUser(currentUid: currentUser.id)
    }
    
    var bottomPadding: CGFloat {
        return shouldShowMessageAvatarView ? 12 : 0
    }
    
    var leadingPadding: CGFloat {
        shouldShowMessageAvatarView ? 0 : AvatarSize.xSmall.dimension + 10
    }
    
    var messageIndex: Int? {
        return viewModel.messages.firstIndex(where: { $0.id == message.id })
    }
    
    var nextMessage: ChatMessage? {
        guard let messageIndex, messageIndex < viewModel.messages.count - 1 else { return nil }
        return viewModel.messages[messageIndex + 1]
    }
    
    var previousMessage: ChatMessage? {
        guard let messageIndex, messageIndex != 0 else { return nil }
        return viewModel.messages[messageIndex - 1]
    }
    
    var shouldShowMessageAvatarView: Bool {
        guard !isMessageFromCurrentUser, let nextMessage else { return true }
        let timeDelta = nextMessage.timestamp.timeIntervalSince(message.timestamp)
        return nextMessage.fromId != message.fromId || timeDelta > ChatConstants.messageGroupingTimeThreshold
    }
    
    var shouldShowUsername: Bool {
        guard viewModel.isGroupThread else { return false }
        guard let previousMessage else { return true }
        let timeDelta = message.timestamp.timeIntervalSince(previousMessage.timestamp)
        return previousMessage.fromId != message.fromId || timeDelta > ChatConstants.messageGroupingTimeThreshold
    }
    
    var shouldShowMessageStatusLabel: Bool {
        guard viewModel.isDirectThread else { return false }
        return message.id == viewModel.messages.last?.id && isMessageFromCurrentUser
    }
    
    var shouldShowMessageTimestampGroupingLabel: Bool {
        guard let previousMessage else { return true }
        let delta = message.timestamp.timeIntervalSince(previousMessage.timestamp)
        return delta > ChatConstants.messageGroupingTimeThreshold
    }
    
    var timestampString: String {
        let messageDate = message.timestamp
        
        if Calendar.current.isDateInToday(messageDate) {
            return "Today \(messageDate.timeString())"
        } else if Calendar.current.isDateInYesterday(messageDate) {
            return "Yesterday at \(messageDate.timeString())"
        } else {
            return "\(messageDate.dateString()) at \(messageDate.timeString())"
        }
    }
}

#Preview {
    ChatMessageCell(message: MockData.mockMessages[0])
        .environment(
            ChatViewModel(
                service: ChatService(),
                thread: nil,
                user: MockData.currentUser
            )
        )
}
