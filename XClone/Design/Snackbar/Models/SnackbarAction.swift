//
//  SnackbarAction.swift
//  XClone
//
//  Created by Stephan Dowless on 2/19/25.
//

import Foundation

public struct SnackbarAction: Identifiable {
    public let id: UUID = .init()
    
    var title: String
    var handler: () -> Void
    
    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

extension SnackbarAction: Equatable {
    public static func == (lhs: SnackbarAction, rhs: SnackbarAction) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
