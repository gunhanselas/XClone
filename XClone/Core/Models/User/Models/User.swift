//
//  User.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

protocol BaseUser: Identifiable, Hashable {
    var id: String { get }
    var email: String? { get }
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
    let email: String?
    var isPrivate: Bool
    var followStats: UserFollowStats
    var createdAt: Date
    var lastActiveAt: Date?
    
    var userRelationState: UserRelationState = .unknown
    
    var isCurrentUser: Bool {
        userRelationState == .isCurrentUser
    }
    
    init(
        id: String,
        username: String,
        profileImageUrl: String? = nil,
        profileHeaderImageUrl: String? = nil,
        fullname: String? = nil,
        bio: String? = nil,
        email: String?,
        isPrivate: Bool,
        followStats: UserFollowStats? = nil,
        createdAt: Date,
        lastActiveAt: Date? = nil,
        userRelationState: UserRelationState? = .unknown
    ) {
        self.id = id
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.profileHeaderImageUrl = profileHeaderImageUrl
        self.fullname = fullname
        self.bio = bio
        self.email = email
        self.isPrivate = isPrivate
        self.followStats = followStats ?? UserFollowStats(followingCount: 0, followersCount: 0)
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.userRelationState = userRelationState ?? .unknown
    }
}
