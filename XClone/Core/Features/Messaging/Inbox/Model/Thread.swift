//
//  Thread.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Foundation

struct Thread: Identifiable, Hashable, Codable {
    let id: String
    var uids: [String]
    var lastMessage: ChatMessage?
    var lastUpdated: Date
    var firstMessageId: String?
    var imageUrl: String?
    var name: String? 
    let type: ThreadType
}

extension Thread {    
    func messageUserID() -> String? {
        guard let lastMessage else { return nil }
//        return type == .direct ? lastMessage.chatPartnerId : lastMessage.fromId
        return nil
    }
}
