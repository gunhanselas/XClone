//
//  FeedEmptyStateView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/27/25.
//

import SwiftUI

struct FeedEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "Your feed is empty.",
            systemImage: "text.page.slash.rtl",
            description: Text("Head to the explore page and follow some users to see their content.")
        )
    }
}

#Preview {
    FeedEmptyStateView()
}
