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
    private var variant: XButtonVariant = .system
    
    init(rank: XButtonRank, size: XButtonSize, iconLayout: XButtonIconLayout, variant: XButtonVariant) {
        self.rank = rank
        self.size = size
        self.iconLayout = iconLayout
        self.variant = variant
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foregroundColor.opacity(configuration.isPressed ? 0.4 : 1.0))
            .frame(width: width, height: height)
            .padding(.horizontal, size == .compact ? 14 : 0)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.4 : 1.0))
            .clipShape(.capsule)
            .overlay {
                if colorScheme == .light && variant == .system {
                    Capsule()
                        .stroke(.gray, lineWidth: 1.0)
                        .opacity(configuration.isPressed ? 0.4 : 1.0)
                }
            }
    }
}

private extension XStandardButtonStyle {
    var backgroundColor: Color {
        switch variant {
        case .primary:
            .primaryBlue
        case .system:
            .white
        }
    }
    
    var foregroundColor: Color {
        switch variant {
        case .primary:
            .white
        case .system:
            .black
        }
    }
    
    var width: CGFloat? {
        switch size {
        case .compact:
            return nil
        case .standard:
            return 360
        }
    }
    
    var height: CGFloat {
        switch size {
        case .compact:
            return 32
        case .standard:
            return 50
        }
    }
}

extension ButtonStyle where Self == XStandardButtonStyle {
    static var standard: XStandardButtonStyle {
        return XStandardButtonStyle(
            rank: .primary,
            size: .standard,
            iconLayout: .leading,
            variant: .system
        )
    }
    
    static func standard(
        rank: XButtonRank = .primary,
        size: XButtonSize = .standard,
        iconLayout: XButtonIconLayout = .leading,
        variant: XButtonVariant = .system
    ) -> Self {
        .init(rank: rank, size: size, iconLayout: iconLayout, variant: variant)
    }
}
