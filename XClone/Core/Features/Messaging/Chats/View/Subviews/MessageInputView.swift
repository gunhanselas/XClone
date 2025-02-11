//
//  MessageInputView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI

struct MessageInputView: View {
    @State private var messageText = ""
    @Environment(ChatViewModel.self) private var viewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            ZStack(alignment: .trailing) {
                TextField("Type a message", text: $messageText, axis: .vertical)
                    .font(.subheadline)
                    .padding(12)
                    .padding(.leading, 4)
                    .padding(.trailing, 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                                
                Button { onSend() } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .disabled(messageText.isEmpty)
                .opacity(messageText.isEmpty ? 0.87 : 1.0)
                .padding(.horizontal)

            }
            .padding(.horizontal, 12)
        }
    }
}

private extension MessageInputView {
    func onSend() {
        Task {
            let messageTextCopy = messageText
            messageText = ""
            await viewModel.sendMessage(messageTextCopy)
        }
    }
}

#Preview {
    MessageInputView()
        .environment(ChatViewModel(service: ChatService(), thread: nil, user: nil))
}
