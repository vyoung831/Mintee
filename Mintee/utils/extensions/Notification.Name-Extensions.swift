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
    
    static var taskSaveFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.taskSaveFailed")
    }
    
    static var taskUpdateFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.taskUpdateFailed")
    }
    
    static var taskDeleteFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.taskDeleteFailed")
    }
    
    static var analysisSaveFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.analysisSaveFailed")
    }
    
    static var analysisUpdateFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.analysisUpdateFailed")
    }
    
    static var analysisDeleteFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.analysisDeleteFailed")
    }
    
    static var analysisReorderFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.analysisReorderFailed")
    }
    
    static var editAnalysis_initFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.editAnalysis_initFailed")
    }
    
    static var editTask_initFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.editTask_initFailed")
    }
    
    static var persistentStore_loadFailed: Notification.Name {
        return .init(rawValue: "Leko.Mintee.persistentStore_loadFailed")
    }
    
}
