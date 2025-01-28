//
//  XStandardButtonStyle.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct XStandardButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    private var rank: XButtonRank
    private var size: XButtonSize
    private var iconLayout: XButtonIconLayout
    
    init(rank: XButtonRank, size: XButtonSize, iconLayout: XButtonIconLayout) {
        self.rank = rank
        self.size = size
        self.iconLayout = iconLayout
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black.opacity(configuration.isPressed ? 0.4 : 1.0))
            .frame(width: width, height: height)
            .background(.white.opacity(configuration.isPressed ? 0.4 : 1.0))
            .clipShape(.capsule)
            .overlay {
                if colorScheme == .light {
                    Capsule()
                        .stroke(.gray, lineWidth: 1.0)
                        .opacity(configuration.isPressed ? 0.4 : 1.0)
                }
            }
    }
}

private extension XStandardButtonStyle {
    var width: CGFloat {
        switch size {
        case .compact:
            return 72
        case .standard:
            return 360
        }
    }
    
    var height: CGFloat {
        switch size {
        case .compact:
            return 36
        case .standard:
            return 50
        }
    }
}

extension ButtonStyle where Self == XStandardButtonStyle {
    static var standard: XStandardButtonStyle {
        return XStandardButtonStyle(rank: .primary, size: .standard, iconLayout: .leading)
    }
    
    static func standard(
        rank: XButtonRank = .primary,
        size: XButtonSize = .standard,
        iconLayout: XButtonIconLayout = .leading
    ) -> Self {
        .init(rank: rank, size: size, iconLayout: iconLayout)
    }
}
