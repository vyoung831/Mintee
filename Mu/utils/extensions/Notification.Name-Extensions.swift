//
//  Notification.Name+Extensions.swift
//  Mu
//
//  Created by Vincent Young on 10/17/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static var themeChanged: Notification.Name {
        return .init(rawValue: "ThemeManager.themeChanged")
    }
    
}
