//
//  LikesCache.swift
//  XClone
//
//  Created by Stephan Dowless on 2/3/25.
//

import Foundation

class LikesCache: UserActivityCache {
    private var refreshInterval: TimeInterval = 60 * 60 * 24 // 24 hours
    static let shared = LikesCache()
    
    private init() {
        super.init(refreshInterval: refreshInterval, cacheIdentifier: "user-likes")
    }
}
