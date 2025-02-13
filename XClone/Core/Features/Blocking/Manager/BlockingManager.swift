//
//  BlockUserManager.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

@Observable
class BlockingManager {
    private let service: BlockUserService
    
    init(service: BlockUserService) {
        self.service = service
    }
}
