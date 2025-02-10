//
//  InboxEmptyStateView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/10/25.
//

import SwiftUI

struct InboxEmptyStateView: View {
    @Binding var isShowingNewMessageView: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to your inbox!")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Drop a line share posts and more with private conversations between you and others on X.")
                .foregroundStyle(.secondary)
            
            Button { isShowingNewMessageView.toggle() } label: {
                Text("Write a message")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(.primaryBlue)
                    .clipShape(Capsule())
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    InboxEmptyStateView(isShowingNewMessageView: .constant(false))
}
