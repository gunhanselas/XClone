//
//  XFloatingButtonStyle.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI

struct XFloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .imageScale(.large)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(.primaryBlue)
                    .frame(width: 54, height: 54)
                    .shadow(color: .primary.opacity(0.25), radius: 6)
            }
            .padding()
    }
}

extension ButtonStyle where Self == XFloatingButtonStyle {
    static var floating: XFloatingButtonStyle {
        .init()
    }
}
