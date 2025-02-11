//
//  ContentLoadingState.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

enum ContentLoadingState {
    case loading
    case empty
    case error(Error)
    case complete
}

extension ContentLoadingState: Equatable {
    static func == (lhs: ContentLoadingState, rhs: ContentLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.empty, .empty),
            (.complete, .complete):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
