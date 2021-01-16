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
    
    // Error message to present if an unexpected interal error was found in Mu or its persistent storage.
    static let unexpectedErrorMessage = "Oops! Something went wrong. The cows are hard at work fixing it!"
    
    /**
     Records a non-fatal error to report to Crashlytics
     - parameter errorCode: Value of type enum ErrorManager.muError to report as NSError code
     - parameter userInfo: [String:Any] pairs to be reported with error record
     */
    static func recordNonFatal(_ errorCode: ErrorManager.NonFatal,
                               _ userInfo: [String:Any]) -> NSError {
        
        var domain: String
        if let bundleID = Bundle.main.bundleIdentifier {
            domain = bundleID
        } else {
            domain = "Mu"
            Crashlytics.crashlytics().record(error: NSError(domain: domain,
                                                            code: NonFatal.bundleIdentifierWasNil.rawValue,
                                                            userInfo: [:]))
        }
        
        let actualError = NSError(domain: domain, code: errorCode.rawValue, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: actualError)
        return actualError
        
    }
    
    /*
     Enum representing the codes of NSErrors that are reported to Crashlytics and thrown to the UI
     - backendFunctionReceivedInvalidInputParameters: A non-UI function received invalid input that should have already been validated
     */
    enum NonFatal: Int {
        case bundleIdentifierWasNil = 1
        case ttsvWomNil = 2
        case invalidThemeSaved = 3
        case invalidThemeRead = 4
        case updateTodayCollectionViewControllerFailed = 5
        case ttsvGetTargetStringInvalidValues = 6
        case collectionViewCouldNotDequeueResuableCell = 7
        case attemptedToCreateTagWithEmptyName = 8
        case collectionSizerReceivedTotalWidthTooSmall = 9
        case persistentStoreContainedInvalidData = 10
        case dateOperationFailed = 11
        case backendFunctionReceivedInvalidInputParameters = 12
    }
    
}
