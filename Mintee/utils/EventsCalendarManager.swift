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
        try? self.syncReminders()
    }
    
    @objc func storeChanged() {
        try? self.syncReminders()
    }
    
    func resetChanges() {
        eventStore.reset()
        CDCoordinator.moc.rollback()
    }
    
    func postNotification_and_resetChanges(_ notification: Notification.Name) {
        self.resetChanges()
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    /**
     Returns the EKCalendar of the provided type named `Mintee` from the default EKEventSource.
     - parameter type: The type of EKCalendar to retrieve.
     */
    private func getCalendar(_ type: EKEntityType) throws -> EKCalendar {
        if let defaultSource = eventStore.sources.first(where: { $0.title == "Default" }) {
            if let existingCalendar = defaultSource.calendars(for: type).first(where: { $0.title == "Mintee" }) {
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
    private func createReminders(_ instances: Set<TaskInstance>, _ calendar: EKCalendar) throws {
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
    
    /**
     Fetches all TaskInstances from the MOC and syncs data with Reminders.
     For TaskInstances that already have a pointer to an existing EKReminder, the TaskInstance and EKReminder have their completion data compared and synced.
     For Tasklnstances that don't already have EKReminder pointers, or whose EKReminders cannot be fetched, new EKReminders are created and pointers set for them.
     */
    func syncReminders() throws {
        
        let request: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances: Set<TaskInstance> = Set<TaskInstance>()
        do {
            instances = Set<TaskInstance>(try CDCoordinator.moc.fetch(request))
        } catch {
            let _ = ErrorManager.recordNonFatal(.fetchRequest_failed, ["Message" : "EventsCalendarManager.syncReminders() failed to execute NSFetchRequest",
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
                                                                ["Message" : "An error occurred in EventsCalendarManager.syncReminders() when saving an existing reminder to the shared EKEventStore",
                                                                 "error.localizedDescription" : error.localizedDescription])
                            self.postNotification_and_resetChanges(.reminderSyncFailed)
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
                    self.postNotification_and_resetChanges(.reminderSyncFailed)
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
                                                    ["Message" : "An error occurred when committing the EKEventStore or saving the MOC in EventsCalendarManager.syncReminders()",
                                                     "error.localizedDescription" : error.localizedDescription])
                self.postNotification_and_resetChanges(.reminderSyncFailed)
                return
            }
            
        })
        
    }
    
}

// MARK: - EKEvent Adding

extension EventsCalendarManager {
    
    /**
     Given a Set of TaskInstances, creates EKEvents and updates the TaskInstances' pointers to point to the newly created events.
     This function does NOT commit the changes to the shared EKEventStore nor save the shared MOC.
     - parameter instances: The set of TaskInstances to create EKEvents for.
     - parameter calendar: The EKCalendar to add the EKEvents to.
     */
    private func createEvents(_ instances: Set<TaskInstance>, _ calendar: EKCalendar) throws {
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                let userInfo: [String : Any] = ["Message" : "EventsCalendarManager.createEvents() found a TaskInstance whose _date couldn't be converted to a valid Date"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, instance._task.mergeDebugDictionary(userInfo: userInfo))
            }
            let event = EKEvent(eventStore: eventStore)
            event.startDate = date; event.endDate = date
            event.title = instance._task._name
            event.calendar = calendar
            try eventStore.save(event, span: EKSpan.thisEvent, commit: false)
            instance.updateEKEvent(event.eventIdentifier)
        }
    }
    
    /**
     Fetches all TaskInstances from the MOC and creates EKEvents for those that don't point to a valid EKEvent.
     */
    func syncEvents() throws {
        
        let request: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances: Set<TaskInstance> = Set<TaskInstance>()
        do {
            instances = Set<TaskInstance>(try CDCoordinator.moc.fetch(request))
        } catch (let error) {
            throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                              ["Message" : "EventsCalendarManager.syncEvents() failed to execute NSFetchRequest",
                                               "request" : request.debugDescription,
                                               "error.localizedDescription" : error.localizedDescription])
        }
        
        // Filter out the events that have pointers to valid EKEvents
        let calendar = try getCalendar(.event)
        let unmatchedInstances = instances.filter({
            if let eventPointer = $0._ekEvent {
                return eventStore.event(withIdentifier: eventPointer) == nil
            }
            return true
        })

        // Create EKEvents for the TaskInstances without valid EKEvent pointers and save changes
        do {
            try createEvents(unmatchedInstances, calendar)
            try CDCoordinator.moc.save()
            try eventStore.commit()
        } catch {
            resetChanges()
        }
        
    }
    
}
