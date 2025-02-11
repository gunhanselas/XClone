//
//  ChatView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    @State private var scrollPosition = ScrollPosition()
    
    init(thread: Thread?, user: User?) {
        _viewModel = State(
            initialValue: ChatViewModel(service: ChatService(), thread: thread, user: user)
        )
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView()
                    .containerRelativeFrame(.vertical)
            case .error:
                Text("An error ocurred.")
            case .empty:
                VStack {
                    Spacer()
                    Text("Send first message")
                    Spacer()
                }
            case .complete:
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            Text(message.messageText)
                                .frame(height: 400)
                        }
                    }
                    .scrollPosition($scrollPosition)
                    .scrollTargetLayout()
                }
                .scrollDismissesKeyboard(.immediately)
                .defaultScrollAnchor(.bottom)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if shouldShowInputView {
                MessageInputView()
                    .padding(.vertical, 6)
                    .environment(viewModel)
            }
        }
        .task { await viewModel.fetchMessages() }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

private extension ChatView {
    var shouldShowInputView: Bool {
        return viewModel.loadingState == .empty || viewModel.loadingState == .complete
    }
}

#Preview {
    ChatView(thread: nil, user: MockData.users[1])
}
