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
    
    // Error message to present if an unexpected interal error was found.
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
            domain = "Leko.Mu"
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
     */
    enum NonFatal: Int {
        // Miscellaneous error codes
        case bundleIdentifierWasNil = 1
        case dateOperationFailed = 2
        
        // UserDefault error codes
        case userDefaults_containedInvalidValue = 100
        case userDefaults_observedInvalidUpdate = 101
        
        // View object error codes
        case viewObject_unexpectedNilProperty = 200
        case viewFunction_receivedInvalidParms = 201
        case uiCollectionViewController_castDequeuedCellFailed = 202
        case viewObject_didNotContainExpectedObject = 203
        
        // Model/persistent store error codes
        case fetchRequest_failed = 300
        case persistentStore_containedInvalidData = 301
        case modelFunction_receivedInvalidInput = 302
        case modelObjectInitializer_receivedInvalidInput = 303
    }
    
}
