//
//  String+Password.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//


import Foundation

extension String {
    func isValidPassword() -> Bool {
        return self.count > 5
    }
}
