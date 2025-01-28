//
//  Environment+Values.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

private struct LoadingKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

public extension EnvironmentValues {
    var isLoading: Binding<Bool> {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
}
