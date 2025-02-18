//
//  InboxViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import Observation

@Observable
class InboxViewModel {
    var loadingState: ContentLoadingState = .loading
    var threads = [Thread]()
        
    private let service: InboxServiceProtocol
    
    init(service: InboxServiceProtocol) {
        self.service = service
    }
    
    func deleteThread(_ thread: Thread) async {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return }
        
        do {
            threads.remove(at: index)
            try await service.deleteThread(thread)
        } catch {
            threads.insert(thread, at: index)
            print("DEBUG: Failed to delete thread with error: \(error)")
        }
    }
    
    func fetchThreads(for currentUserID: String?) async {
        guard let currentUserID else { return }
        
        do {
            threads = try await service.fetchThreads()
            try await fetchThreadUserData(currentUserID)
            
            loadingState = threads.isEmpty ? .empty : .complete
            await streamThreads()
        } catch {
            loadingState = .error(error)
        }
    }
    
    func streamThreads() async {
        for try await thread in service.threadStream() {
            if let threadIndex = threads.firstIndex(where: { $0.id == thread.id }) {
                threads[threadIndex] = thread
            } else {
                threads.insert(thread, at: 0)
            }
            
            threads.sort {
                let isFirstUnread = $0.lastMessage?.status != .read
                let isSecondUnread = $1.lastMessage?.status != .read

                if isFirstUnread != isSecondUnread {
                    return isFirstUnread
                }
                
                return ($0.lastMessage?.timestamp ?? .distantPast) > ($1.lastMessage?.timestamp ?? .distantPast)
            }
        }
    }
}

private extension InboxViewModel {
    func fetchThreadUserData(_ currentUserID: String) async throws {
        try await withThrowingTaskGroup(of: (Int, User?).self) { group in
            for (index, thread) in threads.enumerated() {
                group.addTask {
                    guard let userID = thread.chatPartnerID(currentUserID: currentUserID) else { return (index, nil) }
                    let user = try await FirestoreConstants.UserCollection.document(userID).getDocument(as: User.self)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                threads[index].lastMessage?.user = user
            }
        }
    }
}
