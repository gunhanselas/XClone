//
//  ChatBubbleClipShape.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI

struct ChatBubbleClipShape: Shape {
    var isFromCurrentUser: Bool
    
    var corners: UIRectCorner {
        return [
            .topLeft,
            .topRight,
            isFromCurrentUser ? .bottomLeft : .bottomRight
        ]
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        return Path(path.cgPath)
    }
}
