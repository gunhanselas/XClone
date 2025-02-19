//
//  InboxService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import FirebaseAuth
import FirebaseFirestore

protocol InboxServiceProtocol {
    func fetchThreads() async throws -> [Thread]
    func threadStream() -> AsyncStream<Thread>
    func deleteThread(_ thread: Thread) async throws
}

class InboxService: InboxServiceProtocol {
    private var firestoreListener: ListenerRegistration?
    
    deinit {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
    
    func deleteThread(_ thread: Thread) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.removeUserFromThread(thread, uid: uid) }
            group.addTask { try await self.deleteThreadIfNecessary(thread) }
            group.addTask { try await self.updateThreadDeletionStructures(thread) }

        }
    }
    
    func fetchThreads() async throws -> [Thread] {
        guard let threads = try await threadsQuery?.getDocuments(as: Thread.self) else { return [] }
        
        return threads.sorted { thread1, thread2 in
            let isFirstUnread = thread1.lastMessage?.status != .read
            let isSecondUnread = thread2.lastMessage?.status != .read
            
            if isFirstUnread != isSecondUnread {
                return isFirstUnread // Prioritize unread messages
            }
            
            return (thread1.lastMessage?.timestamp ?? .distantPast) >
            (thread2.lastMessage?.timestamp ?? .distantPast)
        }
    }
    
    func threadStream() -> AsyncStream<Thread> {
        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.firestoreListener?.remove()
                self?.firestoreListener = nil
                continuation.finish()
            }
            
            self.firestoreListener = threadsQuery?.addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                
                let threads = snapshot.documentChanges
                    .filter { $0.type == .added || $0.type == .modified }
                    .compactMap { try? $0.document.data(as: Thread.self) }
                
                if let thread = threads.first {
                    continuation.yield(thread)
                }
            }
        }
    }
}

private extension InboxService {
    var threadsQuery: Query? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        return FirestoreConstants
            .ThreadsCollection
            .whereField("uids", arrayContains: uid)
            .order(by: "lastUpdated", descending: true)
    }
    
    func removeUserFromThread(_ thread: Thread, uid: String) async throws {
        try await FirestoreConstants.ThreadsCollection.document(thread.id).updateData([
            "uids": FieldValue.arrayRemove([uid])
        ])
    }
    
    func deleteThreadIfNecessary(_ thread: Thread) async throws {
        if thread.uids.count == 1 {
            try await FirestoreConstants.ThreadsCollection.document(thread.id).delete()
        }
    }
    
    func updateThreadDeletionStructures(_ thread: Thread) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerID = thread.chatPartnerID(currentUserID: currentUid) else { return }
        
        if thread.uids.isEmpty {
            try await FirestoreConstants.ThreadsCollection.document(thread.id).delete()
            
            try await FirestoreConstants
                .UserCollection
                .document(chatPartnerID)
                .collection("deleted-threads")
                .document(thread.id)
                .delete()
            
        } else {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let threadData = try Firestore.Encoder().encode(thread)
            
            try await FirestoreConstants
                .UserCollection
                .document(currentUid)
                .collection("deleted-threads")
                .document(thread.id)
                .setData(threadData)
        }
    }
}
