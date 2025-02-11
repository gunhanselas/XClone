//
//  InboxView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct InboxView: View {
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
                        ForEach(viewModel.threads) { thread in
                            ZStack {
                                NavigationLink(value: thread) {
                                    EmptyView()
                                }.opacity(0.0)
                                
                                InboxRowView(thread: thread)
                                    .frame(height: 48)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .searchable(text: $searchText, prompt: "Search...")
                        .listSectionSeparator(.hidden, edges: .top)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.visible)
                        .listStyle(PlainListStyle())
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                        .overlay(alignment: .bottomTrailing) {
                            XButton(systemImage: "envelope") {
                                print("Show new messaage view..")
                            }
                            .buttonStyle(.floating)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingNewMessageView) {
                ComposeMessageView(selectedUser: $selectedUser)
            }
            .navigationDestination(item: $selectedUser) { user in
                ChatView(thread: nil, user: user)
            }
            .task { await viewModel.fetchThreads() }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    InboxView()
}
