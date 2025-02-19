//
//  ChatViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Foundation

@Observable
class ChatViewModel {
    var loadingState: ContentLoadingState = .loading
    var messages = [ChatMessage]()
    var initiateThreadObserver = false
    
    private let service: ChatService
    private let user: User?
    
    private var thread: Thread? {
        didSet { initiateThreadObserver = thread != nil }
    }
    
    var isGroupThread: Bool {
        return thread?.type == .group
    }
    
    var isDirectThread: Bool {
        return thread?.type == .direct
    }
    
    init(service: ChatService = ChatService(), thread: Thread?, user: User?) {
        self.service = service
        self.thread = thread
        self.user = user 
    }
    
    func fetchMessages() async {
        guard let thread else {
            loadingState = .empty
            return
        }
        
        do {
            self.messages = try await service.fetchMessages(for: thread)
            initiateThreadObserver = true
            loadingState = messages.isEmpty ? .empty : .complete
        } catch {
            loadingState = .error(error)
        }
    }
    
    func fetchDirectThreadIfNecessary(with chatPartnerID: String) async {
        guard thread == nil else { return }
        
        do {
            self.thread = try await service.fetchThreadIfNecessary(with: chatPartnerID)
        } catch {
            loadingState = .error(error)
        }
    }
    
    func observeChatStream(for currentUserID: String?) async {
        guard let thread, let currentUserID else { return }
        
        for await message in service.getChatStream(for: thread) {
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index] = message
            } else {
                messages.append(message)
            }
            
            await updateMessageStatusToReadIfNecessary(message, currentUserID: currentUserID)

            if loadingState == .empty {
                loadingState = .complete
            }
        }
    }
    
    func sendMessage(_ messageText: String) async {
        guard let chatPartnerID = user?.id else { return }
        
        do {
            if let thread {
                try await service.uploadMessage(messageText: messageText, to: thread)
            } else {
                let thread = try await service.createThread(chatPartnerID: chatPartnerID)
                self.thread = thread
                try await service.uploadMessage(messageText: messageText, to: thread)
            }
        } catch {
            print("DEBUG: Failed to send message with error: \(error.localizedDescription)")
        }
    }
}

private extension ChatViewModel {
    func updateMessageStatusToReadIfNecessary(_ message: ChatMessage, currentUserID: String) async {
        guard !message.isMessageFromCurrentUser(currentUid: currentUserID),
                message.status == .delivered,
                let thread else { return }
        
        do {
            try await service.updateMessageStatus(message, status: .read, for: thread)
        } catch {
            print("DEBUG: Failed to update message status with error: \(error.localizedDescription)")
        }
    }
}
