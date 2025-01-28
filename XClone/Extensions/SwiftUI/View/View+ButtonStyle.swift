//
//  View+ButtonStyle.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

extension View {
    func buttonStyle<S: ButtonStyle>(_ style: S, isLoading: Binding<Bool>) -> some View {
        self.buttonStyle(style).environment(\.isLoading, isLoading)
    }
}
