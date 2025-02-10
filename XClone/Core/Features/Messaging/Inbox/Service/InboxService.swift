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
    private var threads = [Thread]()
    
    deinit {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
    
    func deleteThread(_ thread: Thread) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.removeUserFromThread(thread, uid: uid) }
            group.addTask { try await self.deleteThreadIfNecessary(thread) }
        }
    }
    
    func fetchThreads() async throws -> [Thread] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await FirestoreConstants
            .ThreadsCollection
            .whereField("uids", arrayContains: currentUid)
            .order(by: "lastUpdated", descending: true)
            .getDocuments()
        
        self.threads = snapshot.documents
            .compactMap({ try? $0.data(as: Thread.self) })
            .sorted { thread1, thread2 in
                let isFirstUnread = thread1.lastMessage?.status != .read
                let isSecondUnread = thread2.lastMessage?.status != .read
                
                if isFirstUnread != isSecondUnread {
                    return isFirstUnread // Prioritize unread messages
                }
                
                return (thread1.lastMessage?.timestamp ?? .distantPast) >
                       (thread2.lastMessage?.timestamp ?? .distantPast)
            }
        
        return threads
    }
    
    func threadStream() -> AsyncStream<Thread> {
        return AsyncStream { continuation in
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
            self.firestoreListener = FirestoreConstants
                .ThreadsCollection
                .whereField("uids", arrayContains: currentUid)
                .order(by: "lastUpdated", descending: true)
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let snapshot, let self else { return }
                    
                    let changes = snapshot.documentChanges.filter({
                        $0.type == .added || $0.type == .modified
                    })
                    
                    changes.compactMap { try? $0.document.data(as: Thread.self) }
                        .filter({ !self.threads.contains($0) })
                        .forEach({ continuation.yield($0) })
                }
        }
    }
}

private extension InboxService {
    func deleteThreadIfNecessary(_ thread: Thread) async throws {
        if thread.uids.count == 1 {
            try await FirestoreConstants.ThreadsCollection.document(thread.id).delete()
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
    
    func updateThreadDeletionStructures(_ thread: Thread, with chatPartnerID: String) async throws {
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
