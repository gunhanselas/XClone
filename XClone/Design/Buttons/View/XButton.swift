//
//  XButton.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct XButton: View {
    @Environment(\.isLoading) var isLoading

    private let title: String?
    private let imageResource: ImageResource?
    private let systemImage: String?
    private let action: () -> Void
    
    init(_ title: String, imageResource: ImageResource? = nil, action: @escaping () -> Void) {
        self.title = title
        self.imageResource = imageResource
        self.action = action
        self.systemImage = nil
    }
    
    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.imageResource = nil
    }
    
    init(systemImage: String, action: @escaping () -> Void) {
        self.title = nil
        self.imageResource = nil
        
        self.action = action
        self.systemImage = systemImage
    }
    
    var body: some View {
        Button { action() } label: {
            HStack(spacing: 6) {
                Group {
                    if isLoading.wrappedValue {
                        ProgressView()
                            .tint(.black)
                    } else {
                        if let imageResource {
                            Image(imageResource)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                        } else if let systemImage {
                            Image(systemName: systemImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                        }
                        
                        if let title {
                            Text(title)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    XButton("Next", action: {})
}
