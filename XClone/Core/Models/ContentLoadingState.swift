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
