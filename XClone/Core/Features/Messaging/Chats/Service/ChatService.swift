//
//  ChatService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/8/25.
//

import FirebaseAuth
import FirebaseFirestore

class ChatService {
    private let fetchLimit = ChatConstants.fetchLimit
    private var lastDoc: DocumentSnapshot?
    private var listenerRegistration: ListenerRegistration?

    deinit {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
}

// MARK: - Sending Messages

extension ChatService {
    func uploadMessage(messageText: String, to thread: Thread) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let messageRef = FirestoreConstants.ThreadsCollection.document()
        let messageId = messageRef.documentID
        let lastUpdated = Date()
        
        let message = createMessage(with: messageText, messageId: messageId, date: lastUpdated, currentUid: currentUid)
        let messageData = try Firestore.Encoder().encode(message)
        
        try await addChatPartnerToThreadIfNecessary(thread)
        try await uploadMessageData(messageId, messageData, thread, lastUpdated)
        try await updateDeletedThreadIfNecessary(thread)
    }
        
    private func addChatPartnerToThreadIfNecessary(_ thread: Thread) async throws {
//        if !thread.uids.contains(chatPartner.id) {
//            try await FirestoreConstants
//                .ThreadsCollection
//                .document(thread.id)
//                .updateData(["uids": FieldValue.arrayUnion([chatPartner.id])])
//        }
    }
    
    private func uploadMessageData(_ messageID: String, _ data: [String: Any], _ thread: Thread, _ timestamp: Date) async throws {
        let batch = Firestore.firestore().batch()
        
        let threadRef = FirestoreConstants.ThreadsCollection.document(thread.id)
        let messageRef = FirestoreConstants.messagesCollection(threadID: thread.id).document(messageID)
        let threadData = [ChatConstants.lastMessage: data, ChatConstants.lastUpdated: timestamp] as [String: Any]
        
        batch.setData(data, forDocument: messageRef)
        batch.updateData(threadData, forDocument: threadRef)
        
        if thread.firstMessageId == nil {
            batch.updateData(["firstMessageId": messageID], forDocument: threadRef)
        }
        
        try await batch.commit()
    }
    
    private func updateDeletedThreadIfNecessary(_ thread: Thread) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if !thread.uids.contains(currentUid) {
            try await FirestoreConstants.ThreadsCollection.document(thread.id).updateData([
                "uids": FieldValue.arrayUnion([currentUid])
            ])
            
            try await FirestoreConstants
                .UserCollection
                .document(currentUid)
                .collection("deleted-threads")
                .document(thread.id)
                .delete()
        }
    }
    
    private func createMessage(with messageText: String, messageId: String, date: Date, currentUid: String) -> ChatMessage {
        return ChatMessage(
            id: messageId,
            fromId: currentUid,
            messageText: messageText,
            timestamp: date,
            imageUrl: nil,
            status: .delivered
        )
    }
}

// MARK: - Message Updates

extension ChatService {
    func updateMessageStatus(_ message: ChatMessage, status: ChatMessageStatus, for thread: Thread) async throws {
        let batch = Firestore.firestore().batch()
        
        var messageCopy = message
        messageCopy.status = status
        let messageData = try Firestore.Encoder().encode(messageCopy)
        
        let threadRef = FirestoreConstants.ThreadsCollection.document(thread.id)
        let messageRef = threadRef.collection("messages").document(message.id)
        
        batch.updateData([ChatConstants.lastMessage: messageData], forDocument: threadRef)
        batch.updateData(["status": status.rawValue], forDocument: messageRef)

        try await batch.commit()
    }
}

// MARK: - Fetching Messages

extension ChatService {
    func getChatStream(for thread: Thread) -> AsyncStream<ChatMessage> {
        AsyncStream { continuation in
            onTerminationOfContinuation(continuation)
            
            self.listenerRegistration = chatQuery(for: thread.id)?
                .limit(to: ChatConstants.listenerLimit)
                .addSnapshotListener { [weak self] snapshot, _ in
                    self?.streamMessages(fromSnapshot: snapshot, continuation: continuation)
                }
        }
    }
    
    func fetchMessages(for thread: Thread) async throws -> [ChatMessage] {
        let snapshot = try await chatQuery(for: thread.id)?.limit(to: fetchLimit).getDocuments()
        if lastDoc == nil { lastDoc = snapshot?.documents.last }
        guard let messages = snapshot?.documents.compactMap({ try? $0.data(as: ChatMessage.self) }) else { return [] }
        return messages.reversed()
    }
    
    private func onTerminationOfContinuation(_ continuation: AsyncStream<ChatMessage>.Continuation) {
        continuation.onTermination = { _ in
            self.listenerRegistration?.remove()
            self.listenerRegistration = nil
            continuation.finish()
        }
    }
    
    private func streamMessages(fromSnapshot snapshot: QuerySnapshot?, continuation: AsyncStream<ChatMessage>.Continuation) {
        let messages = snapshot?.documentChanges
            .filter { $0.type == .added || $0.type == .modified }
            .compactMap { try? $0.document.data(as: ChatMessage.self) }
        
        guard let message = messages?.last else { return }
        
        continuation.yield(message)
    }
    
    private func chatQuery(for threadID: String) -> Query? {
        return FirestoreConstants
            .messagesCollection(threadID: threadID)
            .order(by: "timestamp", descending: true)
    }
}

// MARK: - Thread Helpers

extension ChatService {
    func createThread(chatPartnerID: String) async throws -> Thread {
        guard let currentUid = Auth.auth().currentUser?.uid else { throw AuthenticationError.userNotFound }
        let threadRef = FirestoreConstants.ThreadsCollection.document()
        
        let thread = Thread(
            id: threadRef.documentID,
            uids: [currentUid, chatPartnerID],
            lastMessage: nil,
            lastUpdated: Date(),
            firstMessageId: nil,
            type: .direct
        )
        
        let threadData = try Firestore.Encoder().encode(thread)
        try await threadRef.setData(threadData)
        return thread
    }
    
    func fetchThreadIfNecessary(with chatPartnerID: String) async throws -> Thread? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        let threads = try await FirestoreConstants
            .ThreadsCollection
            .whereField("uids", arrayContains: currentUid)
            .getDocuments(as: Thread.self)
        
        return threads.first(where: { $0.uids.contains(chatPartnerID) })
    }
}
