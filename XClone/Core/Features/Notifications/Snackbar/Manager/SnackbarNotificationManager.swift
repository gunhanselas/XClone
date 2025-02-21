//
//  SnackbarNotificationManager.swift
//  XClone
//
//  Created by Stephan Dowless on 2/20/25.
//

import Foundation

@Observable
class SnackbarNotificationManager {
    var notification: SnackbarNotificationModel?
    
    func show(_ type: SnackbarNotificationModel.NotificationType) {
        self.notification = .init(type: type)
    }
}
