//
//  BlockedUsersCache.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

class BlockedUsersCache: UserActivityCache {
    private var refreshInterval: TimeInterval = 60 * 60 * 24 // 24 hours
    static let shared = BlockedUsersCache()
    
    private init() {
        super.init(refreshInterval: refreshInterval, cacheIdentifier: "blocked-users")
    }
}
