//
//  Post.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let authorID: String
    let timestamp: Date
    let caption: String
    var imageURL: String?
    var engagement: PostEngagement
    
    var didLike: Bool = false
    var didSave: Bool = false
    var didRepost: Bool = false
    
    var author: User?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.authorID = try container.decode(String.self, forKey: .authorID)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.engagement = try container.decode(PostEngagement.self, forKey: .engagement)
        
        self.didLike = try container.decodeIfPresent(Bool.self, forKey: .didLike) ?? false
        self.didSave = try container.decodeIfPresent(Bool.self, forKey: .didSave) ?? false
        self.didRepost = try container.decodeIfPresent(Bool.self, forKey: .didRepost) ?? false 
    }
    
    init(
        id: String,
        authorID: String,
        timestamp: Date,
        caption: String,
        imageURL: String? = nil,
        engagement: PostEngagement,
        didLike: Bool = false,
        didSave: Bool = false,
        didRepost: Bool = false,
        author: User? = nil
    ) {
        self.id = id
        self.authorID = authorID
        self.timestamp = timestamp
        self.caption = caption
        self.imageURL = imageURL
        self.engagement = engagement
        self.didLike = didLike
        self.didSave = didSave
        self.didRepost = didRepost
        self.author = author
    }
}
