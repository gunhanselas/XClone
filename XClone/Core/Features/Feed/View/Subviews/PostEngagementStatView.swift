//
//  PostEngagementStatView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostEngagementStatView: View {
    let imageName: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .imageScale(.medium)
            
            if count != 0 {
                Text("\(count)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(spacing: 16) {
        PostEngagementStatView(imageName: "bubble", count: 200)
        
        PostEngagementStatView(imageName: "bubble", count: 0)
    }
}
