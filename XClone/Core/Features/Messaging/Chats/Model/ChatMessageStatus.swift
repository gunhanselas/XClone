//
//  ChatMessageStatus.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Foundation

enum ChatMessageStatus: Int, Codable {
    case delivered
    case read
    case failedToSend
    
    var description: String {
        switch self {
        case .delivered:
            return "Delivered"
        case .read:
            return "Read"
        case .failedToSend:
            return "Message send failure"
        }
    }
}
