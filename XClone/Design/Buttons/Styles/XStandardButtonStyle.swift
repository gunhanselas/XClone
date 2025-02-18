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
            .font(size == .compact ? .subheadline : .headline)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor.opacity(configuration.isPressed ? 0.4 : 1.0))
            .frame(width: width, height: height)
            .padding(.horizontal, size == .compact ? 18 : 0)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.4 : 1.0))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: 1.0)
                    .opacity(configuration.isPressed ? 0.4 : 1.0)
            }
    }
}

private extension XStandardButtonStyle {
    var backgroundColor: Color {
        switch variant {
        case .primary:
                .primaryBlue
        case .system:
            switch rank {
            case .primary:
                .white
            case .secondary:
                Color(.systemBackground)
            case .tertiary:
                .clear
            }
        }
    }
    
    var borderColor: Color {
        guard variant == .system else { return .clear }
        
        switch rank {
        case .primary:
            return colorScheme == .dark ? .clear : .gray
        case .secondary:
            return .gray
        case .tertiary:
            return .clear
        }
    }
    
    var foregroundColor: Color {
        switch variant {
        case .primary:
            return .white
        case .system:
            switch rank {
            case .primary:
                return .black
            case .secondary, .tertiary:
                return Color(.primaryText)
            }
        }
    }
    
    var width: CGFloat? {
        switch size {
        case .compact:
            return nil
        case .standard:
            switch rank {
            case .primary, .secondary:
                return 360
            case .tertiary:
                return nil
            }
        }
    }
    
    var height: CGFloat? {
        switch size {
        case .compact:
            return 34
        case .standard:
            switch rank {
            case .primary, .secondary:
                return 50
            case .tertiary:
                return nil
            }
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
