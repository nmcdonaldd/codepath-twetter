//
//  NotificationCenterNames.swift
//  twetter
//
//  Created by Nick McDonald on 1/31/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//
import Foundation

enum UserNotificationCenterOps: String {
    case userDidLogout = "UserDidLogOut"
    
    var notification: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}
