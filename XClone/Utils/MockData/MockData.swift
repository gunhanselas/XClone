//
//  MockData.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

struct MockData {
    
    static let currentUser = users[0]
    
    static let users: [User] = [
        .init(
            id: UUID().uuidString,
            username: "batman",
            profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/instagramswiftui-22394.appspot.com/o/profile_images%2F35004D5A-6360-4F72-B010-880254BDD973?alt=media&token=e67e2092-22f2-4b61-b6ca-67151e808efe",
            fullname: "Bruce Wayne",
            bio: "Gotham's Dark Knight",
            email: "batman@gmail.com",
            isPrivate: false,
            stats: .init(followingCount: 20, followersCount: 1000, postsCount: 32),
            createdAt: Date(timeIntervalSinceNow: -1_000_000),
            lastActiveAt: Date(),
            userRelationState: .unknown
        ),
        .init(
            id: UUID().uuidString,
            username: "joker",
            profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/instagramswiftui-22394.appspot.com/o/profile_images%2F43B191E7-9E37-4394-ACDB-F253F9C837AC?alt=media&token=353f617b-fdae-44eb-bf71-0c63ecbabcb3",
            fullname: "Heath Ledger",
            bio: "The Joker",
            email: "joker@gmail.com",
            isPrivate: false,
            stats: .init(followingCount: 20, followersCount: 6000, postsCount: 23),
            createdAt: Date(timeIntervalSinceNow: -3_000_000),
            lastActiveAt: Date(),
            userRelationState: .unknown
        )
    ]
    
    static let post = posts[0]
    
    static let posts: [Post] = [
        Post(
            id: UUID().uuidString,
            authorID: users[0].id,
            timestamp: Date().addingTimeInterval(-3600),
            caption: "It's not who I am underneath, but what I do that defines me. 🦇",
            imageURL: users[0].profileImageUrl,
            engagement: PostEngagement(likesCount: 500, impressionsCount: 8000, commentsCount: 100, repostsCount: 50),
            didLike: true,
            didSave: true,
            didRepost: false,
            author: users[0]
        ),
        Post(
            id: UUID().uuidString,
            authorID: users[1].id,
            timestamp: Date().addingTimeInterval(-7200),
            caption: "Why so serious? Let’s put a smile on that face! 😈",
            imageURL: nil,
            engagement: PostEngagement(likesCount: 1200, impressionsCount: 15000, commentsCount: 300, repostsCount: 120),
            didLike: false,
            didSave: true,
            didRepost: true,
            author: users[1]
        ),
        Post(
            id: UUID().uuidString,
            authorID: users[1].id,
            timestamp: Date().addingTimeInterval(-14400),
            caption: "Introduce a little anarchy, upset the established order, and everything becomes chaos.",
            imageURL: users[1].profileImageUrl,
            engagement: PostEngagement(likesCount: 800, impressionsCount: 12000, commentsCount: 200, repostsCount: 80),
            didLike: true,
            didSave: false,
            didRepost: true,
            author: users[1]
        ),
        Post(
            id: UUID().uuidString,
            authorID: users[0].id,
            timestamp: Date().addingTimeInterval(-28800),
            caption: "Sometimes the truth isn’t good enough. Sometimes people deserve more. They deserve to have their faith rewarded.",
            imageURL: nil,
            engagement: PostEngagement(likesCount: 400, impressionsCount: 7000, commentsCount: 50, repostsCount: 20),
            didLike: false,
            didSave: true,
            didRepost: false,
            author: users[0]
        )
    ]
}
