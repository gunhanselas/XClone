//
//  PostEngagementStatView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct PostEngagementStatView: View {
    private let imageName: String
    private let imageForegroundColor: Color
    private let count: Int
    
    init(imageName: String, imageForegroundColor: Color = .secondary, count: Int) {
        self.imageName = imageName
        self.imageForegroundColor = imageForegroundColor
        self.count = count
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .imageScale(.medium)
            
            if count != 0 {
                Text("\(count)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(imageForegroundColor)
    }
}

#Preview {
    VStack(spacing: 16) {
        PostEngagementStatView(imageName: "bubble", count: 200)
        
        PostEngagementStatView(imageName: "bubble", count: 0)
    }
}
