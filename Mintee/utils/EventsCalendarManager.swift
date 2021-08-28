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

// MARK: - Authorization handling

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

// MARK: - Calendar and event adding

extension EventsCalendarManager {
    
    var calendar: EKCalendar? {
        if let defaultSource = eventStore.sources.first(where: { $0.title == "Default" }) {
            if let existingCalendar = defaultSource.calendars(for: .event).first(where: { $0.title == "Mintee" }) {
                return existingCalendar
            } else {
                let calendar = EKCalendar(for: EKEntityType.event, eventStore: eventStore)
                calendar.title = "Mintee"
                calendar.source = defaultSource
                do {
                    try eventStore.saveCalendar(calendar, commit: true)
                    return calendar
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
    /**
     Adds EKEvents to the `Mintee` Calendar for a Task.
     - parameter task: The Task for which to add Calendar events for.
     */
    func addEvents(task: Task) throws {
        guard let taskType = SaveFormatter.storedToTaskType(task._taskType) else {
            let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.addEvents() found a Task whose _taskType couldn't be converted to a valid value of type SaveFormatter.TaskType"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
        }
        
        var instances: Set<TaskInstance> = Set()
        switch taskType {
        case .recurring:
            if let unwrappedInstances = task._instances as? Set<TaskInstance> {
                instances = unwrappedInstances
            }
            break
        case .specific:
            if let unwrappedInstances = task._instances as? Set<TaskInstance> {
                instances = unwrappedInstances
            } else {
                let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.addEvents() found a Specific-type Task with nil _instances"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            }
            break
        }
        
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.addEvents() found a TaskInstance whose _date couldn't be converted to a valid Date"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            }
            let event = EKEvent(eventStore: eventStore)
            event.title = task._name
            event.startDate = date; event.endDate = date
            event.calendar = calendar
            do {
                try eventStore.save(event, span: EKSpan.thisEvent)
            } catch {
                throw error
            }
        }
    }
    
}
