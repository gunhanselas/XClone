//
//  View+Snackbar.swift
//  XClone
//
//  Created by Stephan Dowless on 2/19/25.
//

import SwiftUI

public extension View {
    func snackbar(
        message: String,
        systemImage: String? = nil,
        duration: SnackbarDuration = .duration1,
        entryPosition: SnackbarEntryPosition = .bottom,
        show: Binding<Bool>,
        accessoryAction: SnackbarAction? = nil 
    ) -> some View {
        modifier(
            SnackbarModifier(
                message: message,
                systemImage: systemImage,
                duration: duration,
                entryPosition: entryPosition,
                show: show
            )
        )
    }
}
