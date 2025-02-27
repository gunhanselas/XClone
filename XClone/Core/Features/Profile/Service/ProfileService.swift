//
//  ProfileService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchPosts(for uid: String) async throws -> [Post]
    func fetchReplies(for uid: String) async throws -> [Post]
    func fetchLikedPosts(for uid: String) async throws -> [Post]
}

struct ProfileService: ProfileServiceProtocol {
    func fetchPosts(for uid: String) async throws -> [Post] {
        return try await FirestoreConstants
            .PostsCollection
            .whereField("authorID", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
    }
    
    func fetchReplies(for uid: String) async throws -> [Post] {
        let postIDs = try await FirestoreConstants
            .userRepliesCollection(uid: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return try await withThrowingTaskGroup(of: Post.self) { group in
            var result = [Post]()
            
            for postID in postIDs.documents {
                group.addTask {
                    return try await FirestoreConstants
                        .PostsCollection
                        .document(postID.documentID)
                        .getDocument(as: Post.self)
                }
            }
            
            for try await post in group {
                result.append(post)
            }
            
            return result
        }
    }
    
    func fetchLikedPosts(for uid: String) async throws -> [Post] {
        let postIDs = try await FirestoreConstants
            .userLikesCollection(uid: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments()
                        
        return try await withThrowingTaskGroup(of: Post.self) { group in
            var result = [Post]()
            
            for postID in postIDs.documents {
                group.addTask {
                    
                    return try await FirestoreConstants
                        .PostsCollection
                        .document(postID.documentID)
                        .getDocument(as: Post.self)
                }
            }
            
            for try await post in group {
                result.append(post)
            }
            
            return result
        }
    }
}
