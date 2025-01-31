//
//  ProfileViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

@Observable
class ProfileViewModel {

    func posts(for filter: ProfileContentFilterModel, uid: String) -> [Post] {
        switch filter {
        case .posts:
            return MockData.posts.filter({ $0.authorID == uid })
        case .replies:
            return []
        case .likes:
            return []

        }
    }
}
