//
//  Date+Timestamp.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

extension Date {
    func timestampString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self, to: Date()) ?? ""
    }
}
