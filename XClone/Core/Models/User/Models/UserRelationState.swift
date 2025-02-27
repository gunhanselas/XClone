//
//  UserRelationState.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

enum UserRelationState: Codable {
    case unknown
    case isCurrentUser
    case notFollowed
    case followed
    case blocked
}
