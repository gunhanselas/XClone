//
//  User.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

protocol BaseUser: Identifiable, Hashable {
    var id: String { get }
    var email: String { get }
    var fullname: String? { get }
    var username: String { get }
}

struct User: BaseUser, Codable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var profileHeaderImageUrl: String?
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
