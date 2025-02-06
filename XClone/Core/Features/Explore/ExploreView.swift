//
//  ExploreView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            UserListView(config: .explore)
        }
    }
}

#Preview {
    ExploreView()
}
