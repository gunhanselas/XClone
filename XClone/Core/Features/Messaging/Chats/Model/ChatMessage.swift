//
//  ChatMessage.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import FirebaseAuth
import Foundation

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: String
    let fromId: String
    var messageText: String
    let timestamp: Date
    var imageUrl: String?
    var status: ChatMessageStatus
    var user: User?
}

extension ChatMessage {
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
}
