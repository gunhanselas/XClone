//
//  AvatarSize.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

enum AvatarSize {
    case xSmall
    case small
    case medium
    case large
    
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
        }
    }
}
