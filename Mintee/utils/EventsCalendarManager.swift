//
//  EventsCalendarManager.swift
//  Mintee
//
//  Created by Vincent Young on 8/23/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import EventKit

// MARK: - Initializers + utility functions

class EventsCalendarManager: NSObject {
    
    static var shared = EventsCalendarManager()
    
    var eventStore: EKEventStore
    
    override init() {
        eventStore = EKEventStore()
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: .EKEventStoreChanged, object: eventStore)
        NotificationCenter.default.addObserver(self, selector: #selector(mocChanged), name: .NSManagedObjectContextDidSave, object: CDCoordinator.moc)
    }
    
    @objc func mocChanged() {
        try? self.syncWithReminders()
    }
    
    @objc func storeChanged() {
        try? self.syncWithReminders()
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
    
}

// MARK: - Auth and access

extension EventsCalendarManager {
    
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
    
}

// MARK: - Reminder creation and syncing

extension EventsCalendarManager {
    
    /**
     Given a Set of TaskInstances, creates EKReminders and updates the TaskInstances' pointers to point to the newly created reminders.
     This function does NOT commit the changes to the shared EKEventStore nor save the shared MOC.
     - parameter instances: The set of TaskInstances to create EKReminders for.
     - parameter calendar: The EKCalendar to add the EKReminders to.
     */
    func createReminders(_ instances: Set<TaskInstance>, _ calendar: EKCalendar) throws {
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.createReminders() found a TaskInstance with a _date that couldn't be converted to a valid Date",
                                                "TaskInstance" : instance.debugDescription]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, instance._task.mergeDebugDictionary(userInfo: userInfo))
            }
            let reminder = EKReminder(eventStore: EventsCalendarManager.shared.eventStore)
            reminder.title = instance._task._name
            reminder.isCompleted = instance._completion > 0
            reminder.startDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
            reminder.dueDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
            reminder.calendar = calendar
            do {
                try EventsCalendarManager.shared.eventStore.save(reminder, commit: false)
            } catch {
                throw ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                    ["Message" : "An error occurred in EventsCalendarManager.createReminders() when saving a new EKReminder to the shared EKEventStore",
                                                     "error.localizedDescription" : error.localizedDescription])
            }
            instance.updateEKReminder(reminder.calendarItemIdentifier)
        }
    }
    
    func failReminderSync_and_resetChanges () {
        NotificationCenter.default.post(name: .reminderSyncFailed, object: nil)
        eventStore.reset()
        CDCoordinator.moc.rollback()
    }
    
    /**
     Fetches all TaskInstances from the MOC and syncs data with Reminders.
     For TaskInstances that already have a pointer to an existing EKReminder, the TaskInstance and EKReminder have their completion data compared and synced.
     For Tasklnstances that don't already have EKReminder pointers, or whose EKReminders cannot be fetched, new EKReminders are created and pointers set for them.
     */
    func syncWithReminders() throws {
        
        let request: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances: Set<TaskInstance> = Set<TaskInstance>()
        do {
            instances = Set<TaskInstance>(try CDCoordinator.moc.fetch(request))
        } catch {
            let _ = ErrorManager.recordNonFatal(.fetchRequest_failed, ["Message" : "EventsCalendarManager.syncWithReminders() failed to execute NSFetchRequest",
                                                                       "request" : request.debugDescription,
                                                                       "error.localizedDescription" : error.localizedDescription])
        }
        
        // Fetch all EKReminders in the appropriate Mintee calendar and compare/sync completion data between fetched EKReminders and TaskInstances that point to them.
        EventsCalendarManager.shared.eventStore.refreshSourcesIfNecessary()
        let calendar = try EventsCalendarManager.shared.getCalendar(.reminder)
        let reminderPredicate = EventsCalendarManager.shared.eventStore.predicateForReminders(in: [calendar])
        
        EventsCalendarManager.shared.eventStore.fetchReminders(matching: reminderPredicate, completion: { fetchedReminders in
            
            var changesMade: Bool = false
            let reminders = fetchedReminders ?? []
            for instance in instances {
                // If the pointed-to EKReminder was fetched, compare/sync values and last-modified Dates and remove the TaskInstance from the fetch results.
                if let matchedReminder = reminders.first(where: { $0.calendarItemIdentifier == instance._ekReminder }) {
                    if instance.syncWithReminder(matchedReminder) {
                        changesMade = true
                        do {
                            try EventsCalendarManager.shared.eventStore.save(matchedReminder, commit: false)
                        } catch {
                            let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                                ["Message" : "An error occurred in EventsCalendarManager.syncWithReminders() when saving an existing reminder to the shared EKEventStore",
                                                                 "error.localizedDescription" : error.localizedDescription])
                            self.failReminderSync_and_resetChanges()
                            return
                        }
                    }
                    instances.remove(instance)
                }
            }
            
            // Create EKReminders for remaining TaskInstances that had nil EKReminder pointers or pointed to EKReminders that don't exist.
            if instances.count > 0 {
                changesMade = true
                do {
                    try self.createReminders(instances, calendar)
                } catch {
                    self.failReminderSync_and_resetChanges()
                }
            }
            
            /*
             At this point, MOC and EKEventStore data should all be synced.
             If changes were made, committing the event store and saving the MOC will post Notifications and trigger the shared EventsCalendarManager to call syncWithReminders() once or twice again, but changes should not be detected those times.
             */
            do {
                changesMade ? try EventsCalendarManager.shared.eventStore.commit() : nil
                changesMade ? try CDCoordinator.moc.save() : nil
            } catch {
                let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                    ["Message" : "An error occurred when committing the EKEventStore or saving the MOC in EventsCalendarManager.syncWithReminders()",
                                                     "error.localizedDescription" : error.localizedDescription])
                self.failReminderSync_and_resetChanges()
                return
            }
            
        })
        
    }
    
}

// MARK: - Event/Reminder Adding

extension EventsCalendarManager {
    
    /**
     Adds Calendar events or Reminders to the `Mintee` Calendar for an array of Tasks with the same name.
     - parameter type: The type of EKEntity (EKReminder or EKEvent) to add.
     */
    func addEvents(type: EKEntityType) throws {
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        var tasks: [Task] = []
        do {
            tasks = try CDCoordinator.moc.fetch(request)
        } catch (let error) {
            throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                              ["Message" : "EventsCalendarManager.addEvents() failed to execute NSFetchRequest",
                                               "request" : request.debugDescription,
                                               "error.localizedDescription" : error.localizedDescription])
        }
        
        let groupedTasks = Dictionary(grouping: tasks, by: {
            $0._name
        })
        
        for (_, group) in groupedTasks {
            for task in group {
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
                        try eventStore.save(event, span: EKSpan.thisEvent, commit: false)
                        instance.updateEKEvent(event.eventIdentifier)
                        break
                    case .reminder:
                        let reminder = EKReminder(eventStore: eventStore)
                        reminder.title = task._name
                        reminder.isCompleted = false
                        reminder.startDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
                        reminder.dueDateComponents = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year), from: date)
                        reminder.calendar = calendar
                        try eventStore.save(reminder, commit: false)
                        instance.updateEKReminder(reminder.calendarItemIdentifier)
                        break
                    @unknown default:
                        break
                    }
                }
                
                do {
                    try CDCoordinator.moc.save()
                    try eventStore.commit()
                } catch {
                    failReminderSync_and_resetChanges()
                }
                
            }
            
        }
        
    }
    
}
