//
//  InboxView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct InboxView: View {
    @Environment(UserManager.self) private var userManager
    
    @State private var viewModel = InboxViewModel(service: InboxService())
    @State private var isShowingNewMessageView = false
    @State private var searchText = ""
    @State private var selectedUser: User?

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingState {
                case .empty:
                    InboxEmptyStateView(isShowingNewMessageView: $isShowingNewMessageView)
                case .error:
                    Text("An error ocurred.")
                case .loading:
                    ProgressView()
                        .containerRelativeFrame(.vertical)
                case .complete:
                    List {
                        VStack {
                            ForEach(viewModel.threads) { thread in
                                ZStack {
                                    NavigationLink(value: thread) {
                                        EmptyView()
                                    }.opacity(0.0)
                                    
                                    InboxRowView(thread: thread)
                                        .padding(.horizontal, 8)
                                        .environment(viewModel)
                                }
                            }
                        }
                        .searchable(text: $searchText, prompt: "Search...")
                        .listSectionSeparator(.hidden, edges: .top)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.visible)
                    .listStyle(PlainListStyle())
                }
            }
            .sheet(isPresented: $isShowingNewMessageView) {
                ComposeMessageView(selectedUser: $selectedUser)
            }
            .navigationDestination(for: Thread.self) { thread in
                ChatView(thread: thread, user: thread.lastMessage?.user)
            }
            .navigationDestination(item: $selectedUser) { user in
                ChatView(thread: nil, user: user)
            }
            .task { await viewModel.fetchThreads(for: userManager.currentUser?.id) }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    InboxView()
}
