//
//  UserPostReply.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Foundation

struct UserPostReply: Codable {
    let uid: String
    let postId: String
    let timestamp: Date
}
