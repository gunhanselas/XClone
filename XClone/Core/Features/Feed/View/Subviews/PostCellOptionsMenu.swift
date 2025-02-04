//
//  PostCellOptionsMenu.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct PostCellOptionsMenu: View {
    var body: some View {
        Menu {
            Button("Report Post", action: {})
            
            Menu("@batman") {
                Button("Unfollow", action: {})
                Button("Block", action: {})
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    PostCellOptionsMenu()
}
