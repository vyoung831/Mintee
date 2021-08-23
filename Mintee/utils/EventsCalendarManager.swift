//
//  EventsCalendarManager.swift
//  Mintee
//
//  Created by Vincent Young on 8/23/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

class EventsCalendarManager: NSObject {

    static var shared = EventsCalendarManager()
    
    var eventStore: EKEventStore

    override init() {
        eventStore = EKEventStore()
    }
    
    /**
     Request EKEventStore access to Calendar events
     - parameter completion: Escaping completion handler that takes (Bool, Error)
     */
    func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }

    /**
     - returns: The EventKit authorization status for Calendar Events.
     */
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }

}
