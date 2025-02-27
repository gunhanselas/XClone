//
//  SnackbarNotificationModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/20/25.
//

import Foundation

struct SnackbarNotificationModel: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let type: NotificationType
    
    var title: String {
        switch type {
        case .noInternetConnection:
            "No internet."
        case .blocked(let user):
            "You blocked \(user.username)."
        case .reported:
            "Your report was sent."
        case .postUploaded:
            "Your post was sent."
        case .followed(let user):
            "You followed \(user.username)"
        case .unfollowed(let user):
            "You unfollowed \(user.username)"
        }
    }
    
    enum NotificationType: Identifiable, Hashable {
        case noInternetConnection
        case blocked(User)
        case reported
        case postUploaded
        case followed(User)
        case unfollowed(User)
        
        var id: Int { self.hashValue }
    }
}
