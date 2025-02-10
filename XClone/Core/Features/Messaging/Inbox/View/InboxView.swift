//
//  InboxView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct InboxView: View {
    @State private var viewModel = InboxViewModel(service: InboxService())
    @State private var searchText = ""
    
    var body: some View {
        List {
            Group {
                switch viewModel.loadingState {
                case .empty:
                    Text("No messages")
                case .error(let error):
                    Text(error.localizedDescription)
                case .loading:
                    VStack {
                        ProgressView()
                            .containerRelativeFrame(.vertical)
                    }
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
                        .listSectionSeparator(.hidden, edges: .top)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search...")
            .listRowSeparator(.visible)
            .listStyle(PlainListStyle())
        }
    }
}

#Preview {
    InboxView()
}
