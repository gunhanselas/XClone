//
//  ChatConstants.swift
//  XClone
//
//  Created by Stephan Dowless on 2/7/25.
//

struct ChatConstants {
    static let lastMessage = "lastMessage"
    static let lastUpdated = "lastUpdated"
    static let firstMessageID = "firstMessageID"
    
    static let fetchLimit = 20
    static let listenerLimit = 1
    
    static var messageGroupingTimeThreshold: Double {
        let timeIntervalInSeconds: Double = 60 * 5
        return timeIntervalInSeconds
    }
}
