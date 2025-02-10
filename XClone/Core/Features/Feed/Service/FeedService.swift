//
//  FeedService.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol FeedServiceProtocol {
    func fetchPosts() async throws -> [Post]
}

class FeedService: FeedServiceProtocol {
    private var shouldLoadMoreData = true
    private var lastDoc: QueryDocumentSnapshot?
    private let fetchLimit = 10

    func fetchPosts() async throws -> [Post] {
        let postIDs = try await fetchPostIDs()
        return try await fetchPosts(with: postIDs)
    }
    
    private func fetchPostIDs() async throws -> [String] {
        guard let uid = Auth.auth().currentUser?.uid, shouldLoadMoreData else { return [] }
        
        let query = FirestoreConstants
            .userFeedCollection(uid: uid)
            .order(by: "timestamp", descending: true)
            .limit(to: fetchLimit)
        
        let snapshot: QuerySnapshot
        
        if let lastDoc {
            let next = query.start(afterDocument: lastDoc)
            snapshot = try await next.getDocuments()
            shouldLoadMoreData = snapshot.documents.last != nil
            
            if let lastId = snapshot.documents.last {
                self.lastDoc = lastId
            }
        } else {
            snapshot = try await query.getDocuments()
            shouldLoadMoreData = snapshot.documents.count == fetchLimit
            lastDoc = snapshot.documents.last
        }
        
        return snapshot.documents.map { $0.documentID }
    }
    
    private func fetchPosts(with postIDs: [String]) async throws -> [Post] {
        var result = [Post]()
        
        try await withThrowingTaskGroup(of: Post.self) { group in
            for id in postIDs {
                group.addTask {
                    return try await FirestoreConstants
                        .PostsCollection
                        .document(id)
                        .getDocument(as: Post.self)
                }
            }
            
            for try await post in group {
                result.append(post)
            }
        }
        
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
}
