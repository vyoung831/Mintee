//
//  Notification.Name+Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 10/17/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static private let mintee_bundleQualifier = "Leko.Mintee."
    
    static var themeChanged: Notification.Name {
        return .init(rawValue: "\(Notification.Name.mintee_bundleQualifier)themeChanged")
    }
    
    static var reminderSync_partiallyFailed: Notification.Name {
        return .init(rawValue: "\(Notification.Name.mintee_bundleQualifier)reminderSync_partiallyFailed")
    }
    
    static var reminderSync_saveFailed: Notification.Name {
        return .init(rawValue: "\(Notification.Name.mintee_bundleQualifier)reminderSync_saveFailed")
    }
    
}
