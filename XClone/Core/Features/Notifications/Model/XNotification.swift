//
//  XNotification.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

struct XNotification: Identifiable, Codable {
    let id: String
    let type: XNotificationType
    let senderId: String
    let timestamp: Date
    var postId: String?
    
    var sender: User?
    var post: Post? 
}

enum XNotificationType: Int, Codable {
    case like
    case reply
    case repost
    case follow
}
