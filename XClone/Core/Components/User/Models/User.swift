//
//  User.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var fullname: String?
    var bio: String?
    let email: String
    var isPrivate: Bool
    var stats: UserStats?
    var createdAt: Date
    var lastActiveAt: Date?
    
    var userRelationState: UserRelationState = .unknown
    
    var isCurrentUser: Bool {
        userRelationState == .isCurrentUser
    }
}
