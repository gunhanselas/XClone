//
//  UIApplication+Editing.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
