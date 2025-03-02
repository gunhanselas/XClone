//
//  InboxViewModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import FirebaseAuth
import SwiftUI

@MainActor
class InboxViewModel: ObservableObject {
    @Published var loadingState: ContentLoadingState = .loading
    @Published var threads = [Thread]()
    @Published var unreadMessageCount = 0
    
    private let service: InboxServiceProtocol
    private let userService: UserServiceProtocol
    private var currentUserID: String?
    private var deletedThreads = [Thread]()
    
    init(service: InboxServiceProtocol = InboxService(), userService: UserServiceProtocol = UserService()) {
        self.service = service
        self.userService = userService
        
        Task { await fetchUserDeletedThreads() }
        Task { await fetchThreads() }
    }
    
    func setUnreadMessageCount() {
        guard let currentUserID else { return }
        
        self.unreadMessageCount = threads.count(where: { thread in
            guard let lastMessage = thread.lastMessage else { return false }
            return !lastMessage.isMessageFromCurrentUser(currentUid: currentUserID) && lastMessage.status != .read
        })
    }
    
    func deleteThread(_ thread: Thread) async {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return }
        
        do {
            threads.remove(at: index)
            try await service.deleteThread(thread)
            deletedThreads.append(thread)
        } catch {
            threads.insert(thread, at: index)
            print("DEBUG: Failed to delete thread with error: \(error)")
        }
    }
    
    func fetchThreads() async {
        guard let currentUserID = Auth.auth().currentUser?.uid, threads.isEmpty else { return }
        self.currentUserID = currentUserID
        
        do {
            threads = try await service.fetchThreads()
            try await fetchThreadUserData(currentUserID)
            loadingState = threads.isEmpty ? .empty : .complete
            setUnreadMessageCount()
            
            await streamThreads()
        } catch {
            loadingState = .error(error)
        }
    }
    
    func getThread(withUser user: User) -> Thread? {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return nil }
        
        if let thread = threads.first(where: { $0.chatPartnerID(currentUserID: currentUserID) == user.id }) {
            return thread
        }
        
        if let thread = deletedThreads.first(where: { $0.chatPartnerID(currentUserID: currentUserID) == user.id }) {
            return thread
        }
        
        return nil
    }
    
    func streamThreads() async {
        for try await thread in service.threadStream() {
            if let threadIndex = threads.firstIndex(where: { $0.id == thread.id }) {
                await updateExistingThread(thread, with: threadIndex)
            } else {
                createNewThread(thread)
            }
        }
    }
}

private extension InboxViewModel {
    func createNewThread(_ thread: Thread) {
        threads.append(thread)
        threads.sort(by: { $0.lastUpdated > $1.lastUpdated })
        
        if loadingState == .empty {
            loadingState = .complete
        }
    }
    
    func updateExistingThread(_ thread: Thread, with threadIndex: Int) async {
        guard let currentUserID else { return }
        var copy = thread

        if let chatPartner = threads[threadIndex].lastMessage?.user {
            copy.lastMessage?.user = chatPartner
        } else {
            guard let chatPartnerID = thread.chatPartnerID(currentUserID: currentUserID) else { return }
            let user = try? await userService.fetchUser(withUid: chatPartnerID)
            copy.lastMessage?.user = user
        }
                
        self.threads.remove(at: threadIndex)
        self.threads.insert(copy, at: 0)
        
        guard let lastMessage = threads[threadIndex].lastMessage else { return }
        setUnreadMessageCount()
    }
    
    func fetchThreadUserData(_ currentUserID: String) async throws {
        try await withThrowingTaskGroup(of: (Int, User?).self) { [weak self] group in
            guard let self else { return }
            
            for (index, thread) in threads.enumerated() {
                group.addTask {
                    guard let userID = thread.chatPartnerID(currentUserID: currentUserID) else { return (index, nil) }
                    let user = try await self.userService.fetchUser(withUid: userID)
                    return (index, user)
                }
            }
            
            for try await (index, user) in group {
                threads[index].lastMessage?.user = user
            }
        }
    }
    
    func fetchUserDeletedThreads() async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        do {
            self.deletedThreads = try await FirestoreConstants
                .deletedThreadsCollection(uid: currentUid)
                .getDocuments(as: Thread.self)
        } catch {
            print("DEBUG: Failed to fetch deleted threads with error")
        }
    }
}
