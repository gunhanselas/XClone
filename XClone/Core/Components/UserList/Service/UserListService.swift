//
//  UserListService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import Firebase
import FirebaseAuth

protocol UserListServiceProtocol {
    func fetchUsers(forConfig config: UserListConfiguration) async throws -> [User]
}

class UserListService: UserListServiceProtocol {
    private let fetchLimit = 20
    private var lastDoc: QueryDocumentSnapshot?
    private var shouldLoadMoreData = true
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func fetchUsers(forConfig config: UserListConfiguration) async throws -> [User] {
        switch config {
        case .followers(let uid):
            return try await fetchFollowers(uid: uid)
        case .following(let uid):
            return try await fetchFollowing(uid: uid)
        case .likes(let postId):
            return try await fetchPostLikesUsers(postId: postId)
        case .explore, .newMessage:
            return try await fetchAllUsers()
        }
    }
}

private extension UserListService {
    func fetchFollowers(uid: String) async throws -> [User] {
        let query = FirestoreConstants.userFollowerCollection(uid: uid).limit(to: fetchLimit)
        return try await fetchUsers(withQuery: query)
    }
    
    func fetchFollowing(uid: String) async throws -> [User] {
        let query = FirestoreConstants.userFollowingCollection(uid: uid).limit(to: fetchLimit)
        return try await fetchUsers(withQuery: query)
    }
    
    func fetchPostLikesUsers(postId: String) async throws -> [User] {
        let query = FirestoreConstants.postLikesCollection(postId: postId).limit(to: fetchLimit)
        return try await fetchUsers(withQuery: query)
    }
    
    func fetchAllUsers() async throws -> [User] {
        guard shouldLoadMoreData else { return [] }
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        let query = FirestoreConstants.UserCollection.limit(to: fetchLimit)
        let snapshot: QuerySnapshot
        
        if let lastDoc {
            snapshot = try await query.start(afterDocument: lastDoc).getDocuments()
            if let last = snapshot.documents.last { self.lastDoc = last }
        } else {
            snapshot = try await query.getDocuments()
            lastDoc = snapshot.documents.last
        }
        
        shouldLoadMoreData = snapshot.documents.count == fetchLimit

        return snapshot.documents
            .compactMap { try? $0.data(as: User.self) }
            .filter { $0.id != currentUid }
    }
    
    func fetchUsers(withQuery query: Query) async throws -> [User] {
        guard let snapshot = try await paginatedSnapshot(withQuery: query) else { return [] }
        var users = [User]()
        
        try await withThrowingTaskGroup(of: User.self) { [weak self] group in
            guard let self else { return }
            
            for doc in snapshot.documents {
                group.addTask { return try await self.userService.fetchUser(withUid: doc.documentID) }
            }
            
            for try await user in group {
                users.append(user)
            }
        }

        return users
    }
    
    // returns paginated list of user ids
    func paginatedSnapshot(withQuery query: Query) async throws -> QuerySnapshot? {
        guard shouldLoadMoreData else { return nil }
        let snapshot: QuerySnapshot
        
        if let lastDoc {
            snapshot = try await query.start(afterDocument: lastDoc).getDocuments()
            if let last = snapshot.documents.last { self.lastDoc = last }
        } else {
            snapshot = try await query.getDocuments()
            lastDoc = snapshot.documents.last
        }
        
        shouldLoadMoreData = snapshot.documents.count == fetchLimit
        return snapshot
    }
}
