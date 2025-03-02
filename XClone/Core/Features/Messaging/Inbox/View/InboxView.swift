//
//  InboxView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct InboxView: View {
    @Environment(UserManager.self) private var userManager
    
    @State private var isShowingNewMessageView = false
    @State private var searchText = ""
    @State private var selectedUser: User?
    
    @EnvironmentObject private var viewModel: InboxViewModel

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
                        ForEach(viewModel.threads) { thread in
                            ZStack {
                                NavigationLink(value: thread) {
                                    EmptyView()
                                }.opacity(0.0)
                                
                                InboxRowView(thread: thread)
                                    .environmentObject(viewModel)
                            }
                        }
                        .listRowSeparator(.visible)
                        .listSectionSeparator(.hidden, edges: .top)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button { isShowingNewMessageView.toggle() } label: {
                            Image(systemName: "envelope")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background {
                                    Circle()
                                        .fill(.primaryBlue)
                                        .frame(width: 54, height: 54)
                                        .shadow(color: .primary.opacity(0.25), radius: 6)
                                }
                                .padding()
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search...")
                    .listRowInsets(EdgeInsets())
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
                let thread = viewModel.getThread(withUser: user)
                ChatView(thread: thread, user: user)
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    InboxView()
}
