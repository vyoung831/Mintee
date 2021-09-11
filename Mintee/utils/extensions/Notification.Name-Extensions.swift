//
//  Notification.Name+Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 10/17/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static var themeChanged: Notification.Name {
        return .init(rawValue: "ThemeManager.themeChanged")
    }
    
    static var reminderSyncFailed: Notification.Name {
        return .init(rawValue: "EventsCalendarManager.reminderSyncFailed")
    }
    
}
