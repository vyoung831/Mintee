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

class EventsCalendarManager: ObservableObject {
    
    static var shared = EventsCalendarManager()
    
    @Published var isSyncing: Bool = false
    @Published var calendarLinked: Bool
    @Published var remindersLinked: Bool
    var eventStore: EKEventStore
    
    init() {
        eventStore = EKEventStore()
        self.calendarLinked = (EventsCalendarManager.storeAuthStatus(.event) == .authorized)
        self.remindersLinked = (EventsCalendarManager.storeAuthStatus(.reminder) == .authorized)
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: .EKEventStoreChanged, object: eventStore)
        NotificationCenter.default.addObserver(self, selector: #selector(mocChanged), name: .NSManagedObjectContextDidSave, object: CDCoordinator.moc)
    }
    
    @objc func mocChanged() {
        try? self.syncReminders()
    }
    
    @objc func storeChanged() {
        self.calendarLinked = (EventsCalendarManager.storeAuthStatus(.event) == .authorized)
        self.remindersLinked = (EventsCalendarManager.storeAuthStatus(.reminder) == .authorized)
        try? self.syncReminders()
    }
    
    func resetChanges() {
        eventStore.reset()
        CDCoordinator.moc.rollback()
        DispatchQueue.main.async{ EventsCalendarManager.shared.isSyncing = false }
    }
    
    func postNotification_and_resetChanges(_ notification: Notification.Name) {
        self.resetChanges()
        NotificationCenter.default.post(name: notification, object: nil)
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
            switch type {
            case .event:
                DispatchQueue.main.async { EventsCalendarManager.shared.calendarLinked = accessGranted }
                break
            case .reminder:
                DispatchQueue.main.async { EventsCalendarManager.shared.remindersLinked = accessGranted }
                break
            default:
                break
            }
            completion(accessGranted, error)
        }
    }
    
    /**
     - parameter type: The EKEventStore type to check access for.
     - returns: The EventKit authorization status for the Reminders or Calendar event EKStore.
     */
    static func storeAuthStatus(_ type: EKEntityType) -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: type)
    }
    
}

// MARK: - EKSource and EKCalendar utility functions

extension EventsCalendarManager {
    
    /**
     Finds an EKSource that allows EKCalendarItems of the provided type to be saved to.
     Usable iCloud sources take priority over usable local sources.
     This function checks for, in order:
     1. Sources that already contain EKCalendars of the provided EKEntityType.
     2. Sources that allow EKCalendars of the provided EKEntityType.
     3. Source of default calendars (depending on the provided EKEntityType).
     - parameter type: The EKEntityType for which to find the appropriate EKSource to store Mintee data in.
     - returns: (Optional) The EKSource in which to store Mintee data, given the provided EKEntityType. If no appropriate source was found, nil is returned.
     */
    private func getEKSource(_ type: EKEntityType) -> EKSource? {
        
        eventStore.refreshSourcesIfNecessary()
        
        // Iterate through all iCloud and local EKSources and attempt to find one that already contains EKCalendars of the provided type.
        let cloudSources = eventStore.sources.filter({ $0.title == "iCloud" })
        let localSources = eventStore.sources.filter({ $0.sourceType == .local })
        if let populatedCloudSource = cloudSources.first(where: { $0.calendars(for: type).count > 0 }) { return populatedCloudSource }
        if let populatedLocalSource = localSources.first(where: { $0.calendars(for: type).count > 0 }) { return populatedLocalSource }
        
        // Iterate through each iCloud and local source (iCloud first) and attempt to save an EKCalendar of the provided type (without committing). If the save succeeds, backout changes and return the EKSource.
        let combinedSources: [EKSource] = cloudSources + localSources
        for source in combinedSources {
            let calendar = EKCalendar(for: type, eventStore: eventStore); calendar.source = source
            do {
                try eventStore.saveCalendar(calendar, commit: false)
                eventStore.reset()
                return source
            } catch {
                eventStore.reset()
            }
        }
        
        // Attempt to use default calendars' sources.
        switch type {
        case .reminder:
            if let defaultCalendar = eventStore.defaultCalendarForNewReminders() {
                return defaultCalendar.source
            }
            break
        case .event:
            if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
                return defaultCalendar.source
            }
        @unknown default:
            break
        }
        
        return nil
    }
    
    /**
     Creates and returns an EKCalendar named "Mintee" in the appropriate EKSource.
     The new EKCalendar is created, and saved and committed to the EKEventStore.
     - parameter type: The EKEntityType to be supported.
     - returns: A new EKCalendar named "Mintee" supporting the provided EKEntityType, saved and committed to the EKEventStore.
     */
    private func createMinteeCalendar(_ type: EKEntityType) throws -> EKCalendar {
        guard let source = getEKSource(type) else {
            var userInfo: [String : Any] = [:]
            for idx in 0 ..< eventStore.sources.count {
                userInfo[String(idx)] = eventStore.sources[idx]
            }
            throw ErrorManager.recordNonFatal(.ek_couldNotFind_usable_ekSource, userInfo)
        }
        let calendar = EKCalendar(for: type, eventStore: eventStore)
        calendar.title = "Mintee"
        calendar.source = source
        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
    }
    
    /**
     - parameter type: The type of entity that will be added to the calendar.
     - returns: An EKCalendar named 'Mintee' for adding EKEvents/EKReminders to.
     */
    private func getCalendar(_ type: EKEntityType) throws -> EKCalendar {
        eventStore.refreshSourcesIfNecessary()
        if let existingCalendar = eventStore.calendars(for: type).first(where: {$0.title == "Mintee"}) {
            return existingCalendar
        }
        return try createMinteeCalendar(type)
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
            throw ErrorManager.recordNonFatal(.fetchRequest_failed, ["Message" : "EventsCalendarManager.syncReminders() failed to execute NSFetchRequest",
                                                                     "request" : request.debugDescription,
                                                                     "error.localizedDescription" : error.localizedDescription])
        }
        
        // Fetch all EKReminders in the appropriate Mintee calendar and compare/sync completion data between fetched EKReminders and TaskInstances that point to them.
        EventsCalendarManager.shared.eventStore.refreshSourcesIfNecessary()
        let calendar = try EventsCalendarManager.shared.getCalendar(.reminder)
        let reminderPredicate = EventsCalendarManager.shared.eventStore.predicateForReminders(in: [calendar])
        
        /*
         This block will be called by a background thread
         */
        EventsCalendarManager.shared.eventStore.fetchReminders(matching: reminderPredicate, completion: { fetchedReminders in
            
            DispatchQueue.main.async{ EventsCalendarManager.shared.isSyncing = true }
            var changesMade: Bool = false
            var reminders = fetchedReminders ?? []
            for instance in instances {
                // If the pointed-to EKReminder was fetched, compare/sync values and last-modified Dates and remove the TaskInstance from the fetch results.
                if let matchIndex = reminders.firstIndex(where: { $0.calendarItemIdentifier == instance._ekReminder }) {
                    if instance.syncWithReminder(reminders[matchIndex]) {
                        changesMade = true
                        do {
                            try EventsCalendarManager.shared.eventStore.save(reminders[matchIndex], commit: false)
                        } catch {
                            let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                                ["Message" : "An error occurred in EventsCalendarManager.syncReminders() when saving an existing reminder to the shared EKEventStore",
                                                                 "error.localizedDescription" : error.localizedDescription])
                            self.postNotification_and_resetChanges(.reminderSyncFailed)
                            return
                        }
                    }
                    instances.remove(instance)
                    reminders.remove(at: matchIndex)
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
            
            // Remaining EKReminders in reminders are ones that no TaskInstance points to. Delete them
            if reminders.count > 0 {
                changesMade = true
                do {
                    for reminder in reminders {
                        try self.eventStore.remove(reminder, commit: false)
                    }
                } catch {
                    let _ = ErrorManager.recordNonFatal(.ek_removeFailed, ["Message" : "An error occurred in EventsCalendarManager.syncReminders() when removing an EKReminder from the shared EKEventStore",
                                                                           "error.localizedDescription" : error.localizedDescription])
                    self.postNotification_and_resetChanges(.reminderSyncFailed)
                }
            }
            
            /*
             At this point, MOC and EKEventStore data should all be synced.
             If changes were made, committing the event store and saving the MOC will post Notifications and trigger the shared EventsCalendarManager to call syncWithReminders() once or twice again, but changes should not be detected those times.
             */
            do {
                changesMade ? try EventsCalendarManager.shared.eventStore.commit() : nil
                changesMade ? CDCoordinator.shared.saveContext() : nil
                DispatchQueue.main.async{ EventsCalendarManager.shared.isSyncing = false }
                return
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
        if unmatchedInstances.count > 0 {
            do {
                try createEvents(unmatchedInstances, calendar)
                try CDCoordinator.moc.save()
                try eventStore.commit()
            } catch {
                resetChanges()
            }
        }
        
    }
    
}
