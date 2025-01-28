//
//  String+Name.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

extension String {
    func isValidName() -> Bool {
        let nameRegex = "^[a-zA-Zà-ÿÀ-Ÿ'\\-\\s]+$"
        
        let namePred = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePred.evaluate(with: self)
    }
}
