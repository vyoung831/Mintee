//
//  UIUTil.swift
//  Mintee
//
//  Created by Vincent Young on 8/21/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import UIKit

class UIUtil {
    
    /**
     Hides the keyboard (if presented) on the singleton UIApplication instance by sending `resignFirstResponder` selector message to the first responder.
     `to: nil` indicates that the action-message is to be sent to the first responder, which is the keyboard (if presented).
     See the following for more info:
     - https://learnappmaking.com/target-action-swift/
     - https://www.hackingwithswift.com/example-code/system/what-is-the-first-responder
     - https://swiftrocks.com/understanding-the-ios-responder-chain.html
     */
    static func resignFirstResponder() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
}

