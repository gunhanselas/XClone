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
    
    init(thread: Thread?) {
        _viewModel = State(
            initialValue: ChatViewModel(service: ChatService(), thread: thread)
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.messages) { message in
                    Text(message.messageText)
                }
            }
            .scrollTargetLayout()
            .defaultScrollAnchor(.bottom)
        }
    }
}

#Preview {
    ChatView(thread: nil)
}
