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
    
    func fetchThreads() async {
        do {
            threads = try await service.fetchThreads()
            
            loadingState = threads.isEmpty ? .empty : .complete
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
