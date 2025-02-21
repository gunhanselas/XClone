//
//  BlockUserPreferenceKey.swift
//  XClone
//
//  Created by Stephan Dowless on 2/20/25.
//

import SwiftUI

struct BlockUserPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
        print("DEBUG: Value \(value) | next value \(nextValue())")
    }
}
