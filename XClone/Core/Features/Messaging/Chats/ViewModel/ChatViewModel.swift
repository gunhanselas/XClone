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
    private var thread: Thread?
    
    init(service: ChatService, thread: Thread?) {
        self.service = service
        self.thread = thread
    }
    
    func fetchMessages() async {
        guard let thread else { return }
        
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
    
    func observeChatStream() async {
        guard let thread else { return }

        for await message in service.getChatStream(for: thread) {
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index] = message
            } else {
                messages.append(message)
            }
            
            await updateMessageStatusToReadIfNecessary(message)

            if case .empty = loadingState {
                loadingState = .complete
            }
        }
    }
}

private extension ChatViewModel {
    func updateMessageStatusToReadIfNecessary(_ message: ChatMessage) async {
        guard !message.isFromCurrentUser, message.status == .delivered, let thread else { return }
        
        do {
            try await service.updateMessageStatus(message, status: .read, for: thread)
        } catch {
            print("DEBUG: Failed to update message status with error: \(error.localizedDescription)")
        }
    }
}
