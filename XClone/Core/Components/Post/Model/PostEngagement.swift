//
//  PostEngagement.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

struct PostEngagement: Codable, Hashable {
    var likesCount: Int
    var impressionsCount: Int
    var commentsCount: Int
    var repostsCount: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.likesCount = try container.decode(Int.self, forKey: .likesCount)
        self.impressionsCount = try container.decode(Int.self, forKey: .impressionsCount)
        self.commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        self.repostsCount = try container.decode(Int.self, forKey: .repostsCount)
    }
    
    init(likesCount: Int = 0, impressionsCount: Int = 0, commentsCount: Int = 0, repostsCount: Int = 0) {
        self.likesCount = likesCount
        self.impressionsCount = impressionsCount
        self.commentsCount = commentsCount
        self.repostsCount = repostsCount
    }
}
