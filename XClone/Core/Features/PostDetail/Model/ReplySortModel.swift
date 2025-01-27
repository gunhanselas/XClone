//
//  ReplySortModel.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

enum ReplySortModel: Int, CaseIterable {
    case mostRecent
    case mostLiked
}

extension ReplySortModel: Identifiable, Hashable {
    var id: Int { rawValue }
}

extension ReplySortModel: CustomStringConvertible {
    var description: String {
        switch self {
        case .mostRecent:
            return "Most recent replies"
        case .mostLiked:
            return "Most liked replies"
        }
    }
}
