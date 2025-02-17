//
//  FollowCache.swift
//  XClone
//
//  Created by Stephan Dowless on 2/17/25.
//

import Foundation

class FollowCache: UserActivityCache {
    private var refreshInterval: TimeInterval = 60 * 60 * 12 // 24 hours
    static let shared = FollowCache()
    
    init() {
        super.init(refreshInterval: refreshInterval, cacheIdentifier: "user-following")
    }
}
