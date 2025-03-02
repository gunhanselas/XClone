//
//  ChatView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    
    @StateObject private var viewModel: ChatViewModel
    @State private var scrollPosition = ScrollPosition()
    
    private let user: User?
    
    init(thread: Thread?, user: User?) {
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(thread: thread, user: user)
        )
        
        self.user = user
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView()
                    .containerRelativeFrame(.vertical)
            case .error:
                Text("An error ocurred.")
            case .complete, .empty:
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            ChatMessageCell(message: message)
                                .environmentObject(viewModel)
                                .onAppear { loadPreviousMessagesIfNecessary(message) }
                        }
                    }
                    .defaultScrollAnchor(.bottom)
                    .scrollTargetLayout()
                }
                .scrollPosition($scrollPosition)
                .defaultScrollAnchor(.bottom)
                .onTapGesture { UIApplication.shared.endEditing() }
            }
        }
        .navigationTitle(user?.username ?? "Chat")
        .safeAreaInset(edge: .bottom) {
            if shouldShowInputView {
                MessageInputView()
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .environmentObject(viewModel)
            }
        }
        .task { await viewModel.fetchMessages() }
        .task(id: viewModel.initiateThreadObserver) {
            guard viewModel.initiateThreadObserver else { return }
            await viewModel.observeChatStream(for: userManager.currentUser?.id)
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

private extension ChatView {
    func loadPreviousMessagesIfNecessary(_ currentMessage: ChatMessage) {
        guard currentMessage.id == viewModel.messages.first?.id else { return }
        Task { await viewModel.fetchPreviousMessages() }
    }
    
    var shouldShowInputView: Bool {
        return viewModel.loadingState == .empty || viewModel.loadingState == .complete
    }
}

#Preview {
    ChatView(thread: nil, user: MockData.users[1])
}
