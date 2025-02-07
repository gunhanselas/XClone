//
//  AvatarSize.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

enum AvatarSize {
    /// A size of 40x40
    case xSmall
    
    /// A size of 48x48
    case small
    
    /// A size of 64x64
    case medium
    
    /// A size of 80x80
    case large
    
    /// A size of 100x100
    case xLarge
    
    /// Produces a custom size 
    case custom(CGFloat)
    
    var dimension: CGFloat {
        switch self {
        case .xSmall:
            return 40
        case .small:
            return 48
        case .medium:
            return 64
        case .large:
            return 80
        case .xLarge:
            return 100
        case .custom(let size):
            return size
        }
    }
}
