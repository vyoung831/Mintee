//
//  ErrorManager.swift
//  Mu
//
//  Created by Vincent Young on 10/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import Firebase

struct ErrorManager {
    
    /**
     Records a non-fatal error to report to Crashlytics
     - parameter errorCode: Value of type enum ErrorManager.muError to report as NSError code
     - parameter userInfo: [String:Any] pairs to be reported with error record
     */
    static func recordNonFatal(_ errorCode: ErrorManager.Error,
                               _ userInfo: [String:Any]) {
        
        var domain: String
        if let bundleID = Bundle.main.bundleIdentifier {
            domain = bundleID
        } else {
            domain = "Mu"
            Crashlytics.crashlytics().record(error: NSError(domain: domain,
                                                            code: Error.bundleIdentifierWasNil.rawValue,
                                                            userInfo: [:]))
        }
        
        Crashlytics.crashlytics().record(error: NSError(domain: domain,
                                                        code: errorCode.rawValue,
                                                        userInfo: userInfo))
        
    }
    
    enum Error: Int {
        case bundleIdentifierWasNil = 1
        case ttsvWomNil = 2
        case invalidThemeSaved = 3
        case invalidThemeRead = 4
        case updateTodayCollectionViewControllerFailed = 5
    }
    
    
    
}
