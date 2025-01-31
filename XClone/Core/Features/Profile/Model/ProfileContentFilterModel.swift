//
//  ProfileContentFilterModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

enum ProfileContentFilterModel: Int, CaseIterable {
    case posts
    case replies
    case likes
}

extension ProfileContentFilterModel: Identifiable {
    var id: Int { rawValue }
}

extension ProfileContentFilterModel: CustomStringConvertible {
    var description: String {
        switch self {
        case .posts:
            return "Posts"
        case .replies:
            return "Replies"
        case .likes:
            return "Likes"
        }
    }
}
