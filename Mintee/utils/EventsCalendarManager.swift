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
     - parameter type: The type of EKEventStore to request access to.
     - parameter completion: Escaping completion handler.
     */
    func requestStoreAccess(type: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: type) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    /**
     - parameter type: The EKEventStore type to check access for.
     - returns: The EventKit authorization status for the Reminders or Calendar event EKStore.
     */
    func storeAuthStatus(_ type: EKEntityType) -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    /**
     Returns the EKCalendar of the provided type named `Mintee` from the default EKEventSource.
     - parameter type: The type of EKCalendar to retrieve.
     */
    private func getCalendar(_ type: EKEntityType) throws -> EKCalendar {
        if let defaultSource = eventStore.sources.first(where: { $0.title == "Default" }) {
            if let existingCalendar = defaultSource.calendars(for: .reminder).first(where: { $0.title == "Mintee" }) {
                return existingCalendar
            } else {
                let calendar = EKCalendar(for: type, eventStore: eventStore)
                calendar.title = "Mintee"
                calendar.source = defaultSource
                do {
                    try eventStore.saveCalendar(calendar, commit: true)
                    return calendar
                } catch {
                    throw error
                }
            }
        }
        throw ErrorManager.recordNonFatal(.ek_defaultSource_doesNotExist, [:])
    }

    
    /**
     Adds Calendar events or Reminders to the `Mintee` Calendar.
     - parameter type: The type of EKEntity (EKReminder or EKEvent) to add.
     - parameter task: The Task for which to add Calendar events for.
     */
    func addEvents(type: EKEntityType, task: Task) throws {
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
        
        var calendar: EKCalendar?
        switch type {
        case .event:
            calendar = try getCalendar(.event); break
        case .reminder:
            calendar = try getCalendar(.reminder); break
        @unknown default:
            break
        }
        
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.addEvents() found a TaskInstance whose _date couldn't be converted to a valid Date"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            }
            
            switch type {
            case .event:
                let event = EKEvent(eventStore: eventStore)
                event.startDate = date; event.endDate = date
                event.title = task._name
                event.calendar = calendar
                try eventStore.save(event, span: EKSpan.thisEvent)
                break
            case .reminder:
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = task._name
                reminder.isCompleted = false
                reminder.startDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
                reminder.dueDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
                reminder.calendar = calendar
                try eventStore.save(reminder, commit: true)
                break
            @unknown default:
                break
            }
        }
        
    }
    
}
