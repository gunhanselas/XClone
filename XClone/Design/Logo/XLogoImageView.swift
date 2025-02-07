//
//  XLogoImageView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/28/25.
//

import SwiftUI

enum LogoImageSize {
    case small
    case medium
    case large
    
    var dimension: CGSize {
        switch self {
        case .small:
            return CGSize(width: 40, height: 30)
        case .medium:
            return CGSize(width: 80, height: 60)
        case .large:
            return CGSize(width: 140, height: 100)
        }
    }
}

struct XLogoImageView: View {
    @Environment(\.colorScheme) var scheme
    
    private let size: LogoImageSize
    
    init(size: LogoImageSize = .large) {
        self.size = size
    }
    
    var body: some View {
        Image(scheme == .dark ? .xLogoWhite: .xLogo)
            .resizable()
            .frame(width: size.dimension.width, height: size.dimension.height)
    }
}

#Preview {
    XLogoImageView()
}
