//
//  ChatBubbleModifier.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI

struct ChatBubbleModifier: ViewModifier {
    let isFromCurrentUser: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(messageBackgroundColor)
            .foregroundStyle(messageTextColor)
            .clipShape(ChatBubbleClipShape(isFromCurrentUser: isFromCurrentUser))
            .frame(maxWidth: maxWidth, alignment: alignment)
            .padding(.trailing)
    }
}

private extension ChatBubbleModifier {
    var messageBackgroundColor: Color {
        return isFromCurrentUser ? .blue : Color(.secondarySystemBackground)
    }
    
    var messageTextColor: Color {
        return isFromCurrentUser ? .white : .primary
    }
    
    var maxWidth: CGFloat {
        return UIScreen.main.bounds.width / 1.5
    }
    
    var alignment: Alignment {
        return isFromCurrentUser ? .trailing : .leading
    }
}
