//
//  Task+CoreDataClass.swift
//  Mintee
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI
import Firebase

@objc(Task)
public class Task: NSManagedObject {
    
    @NSManaged private var startDate: String?
    @NSManaged private var endDate: String?
    @NSManaged private var taskType: Int16
    @NSManaged private var name: String?
    @NSManaged private var instances: NSSet?
    @NSManaged private var tags: NSSet?
    @NSManaged private var targetSets: NSSet?
    @NSManaged private var taskSummaryAnalysis: TaskSummaryAnalysis?
    
    var _startDate: String? { get { return self.startDate } }
    var _endDate: String? { get { return self.endDate } }
    var _taskType: Int16 { get { return self.taskType } }
    var _name: String? { get { return self.name } set { self.name = newValue } }
    var _instances: NSSet? { get { return self.instances } }
    var _tags: NSSet? { get { return self.tags } }
    var _targetSets: NSSet? { get { return self.targetSets } }
    var _taskSummaryAnalysis: TaskSummaryAnalysis? { get { return self.taskSummaryAnalysis } }
    
    /**
     Convenience init for recurring-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     name: String,
                     tags: Set<Tag>,
                     startDate: Date,
                     endDate: Date,
                     targetSets: Set<TaskTargetSet>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.updateTags(newTags: tags)
        try self.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: targetSets)
    }
    
    /**
     Convenience init for specific-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     name: String,
                     tags: Set<Tag>,
                     dates: [Date]) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.updateTags(newTags: tags)
        try self.updateSpecificInstances(dates: dates)
    }
    
    /**
     Disassociates all Tags from this Task, checks each Tag for deletion, and deletes this task from the shared MOC.
     Also deletes all TaskInstances and TaskTargetSets associated with this Task.
     */
    public func deleteSelf() throws {
        self.removeAllTags()
        
        if let targetSets = self.targetSets,
           let instances = self.instances {
            for case let tts as TaskTargetSet in targetSets { CDCoordinator.moc.delete(tts) }
            for case let ti as TaskInstance in instances { CDCoordinator.moc.delete(ti) }
        } else {
            let userInfo: [String : Any] = ["Message" : "Task.deleteSelf() found instances and/or targetSets to be nil"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        CDCoordinator.moc.delete(self)
    }
    
}

// MARK: Generated accessors for instances
extension Task {
    
    @objc(addInstancesObject:)
    @NSManaged private func addToInstances(_ value: TaskInstance)
    
    @objc(removeInstancesObject:)
    @NSManaged private func removeFromInstances(_ value: TaskInstance)
    
    @objc(addInstances:)
    @NSManaged private func addToInstances(_ values: NSSet)
    
    @objc(removeInstances:)
    @NSManaged private func removeFromInstances(_ values: NSSet)
    
}

// MARK: Generated accessors for tags
extension Task {
    
    @objc(addTagsObject:)
    @NSManaged private func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged private func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged private func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged private func removeFromTags(_ values: NSSet)
    
}

// MARK: Generated accessors for targetSets
extension Task {
    
    @objc(addTargetSetsObject:)
    @NSManaged private func addToTargetSets(_ value: TaskTargetSet)
    
    @objc(removeTargetSetsObject:)
    @NSManaged private func removeFromTargetSets(_ value: TaskTargetSet)
    
    @objc(addTargetSets:)
    @NSManaged private func addToTargetSets(_ values: NSSet)
    
    @objc(removeTargetSets:)
    @NSManaged private func removeFromTargetSets(_ values: NSSet)
    
}

// MARK: - Debug descriptions for error reporting

extension Task {
    
    /**
     Gathers debug descriptions of this Task and its TaskTargetSets.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info
     - returns: Dictionary containing existing debug info and debug descriptions of this Task and its TaskTargetSets
     */
    func mergeDebugDictionary(userInfo: [String : Any]) -> [String : Any] {
        
        var debugDictionary: [String : Any] = [:]
        debugDictionary["Task.debugDescription"] = self.debugDescription
        
        if let ttsArray = self.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                // Add Dictionary entries for TaskTargetSets
                let ttsIdentifier = "Task.TaskTargetSet[\(idx)]"
                debugDictionary["\(ttsIdentifier).debugDescription"] = ttsArray[idx].debugDescription
                
                // Add Dictionary entries for DayPatterns' sets and types
                let patternIdentifier = "\(ttsIdentifier)._pattern"
                if let pattern = ttsArray[idx]._pattern {
                    debugDictionary["\(patternIdentifier).daysOfWeek"] = pattern.daysOfWeek
                    debugDictionary["\(patternIdentifier).weeksOfMonth"] = pattern.weeksOfMonth
                    debugDictionary["\(patternIdentifier).daysOfMonth"] = pattern.daysOfMonth
                    debugDictionary["\(patternIdentifier).type"] = pattern.type
                } else {
                    debugDictionary["\(patternIdentifier)"] = nil
                }
                
            }
        }
        
        debugDictionary.merge(userInfo, uniquingKeysWith: {
            return "(Keys clashed).\nValue 1 = \($0)\nValue 2 = \($1)"
        })
        return debugDictionary
        
    }
    
}


// MARK: - Tag handling

extension Task {
    
    /**
     - returns: An array of strings representing the tagNames of this Task's tags
     */
    public func getTagNames() -> Set<String> {
        if let tags = self.tags as? Set<Tag> {
            let tagNames = Set(tags.map({$0._name ?? ""}))
            return tagNames
        }
        return Set<String>()
    }
    
    /**
     Updates this Task's tags relationship to contain only the Tags passed in.
     Tags that were already associated with this Task but that don't exist in the new tags passed in are removed and checked for possible deletion.
     - parameter newTags: Set of Tags to set as this Task's tags relationship
     */
    public func updateTags(newTags: Set<Tag>) {
        
        // Remove unrelated tags and check for deletion
        self.removeUnrelatedTags(newTags: newTags)
        self.addToTags( NSSet(set: newTags) )
        
    }
    
    /**
     Removes Tags that are no longer to be associated with this Task.
     Tags that were already associated with this Task but that don't exist in the new tags passed in are removed and checked for possible deletion.
     - parameter newTags: Set of Tags to be set as this Task's tags relationship
     */
    private func removeUnrelatedTags(newTags: Set<Tag>) {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                
                if !newTags.contains(tag) {
                    self.removeFromTags(tag)
                    if tag._tasks?.count == 0 {
                        CDCoordinator.moc.delete(tag)
                    }
                }
                
            }
        }
    }
    
    /**
     Removes all Tags from this Task's tags relationship and checks each one of them for deletion
     */
    private func removeAllTags() {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                self.removeFromTags(tag)
                if tag._tasks?.count == 0 {
                    CDCoordinator.moc.delete(tag)
                }
            }
        }
    }
    
}

// MARK: - TaskInstance delta

extension Task {
    
    /**
     Returns the date representations of existing TaskInstances that would be deleted given a new set of Dates for a specific-type Task
     - parameter dates: New dates that would be set as this Task's instances
     - returns: Array of Strings representing TaskInstances that would be deleted, sorted by date. The Strings represent the dates in "M-d-yyyy" format
     */
    func getDeltaInstancesSpecific(dates: Set<Date>) throws -> [String] {
        
        guard let instances = self.instances as? Set<TaskInstance> else {
            let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesSpecific() could not retrieve instances as Set of TaskInstance"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        var datesDelta: [String] = []
        let newDateStrings = dates.map{SaveFormatter.dateToStoredString($0)}
        for instance in instances {
            
            guard let existingDate = instance._date else {
                let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesSpecific() found nil in a TaskInstance's _date"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
            }
            
            !newDateStrings.contains(existingDate) ? datesDelta.append(existingDate) : nil
            
        }
        
        return datesDelta.sorted{ $0 < $1 }
    }
    
    /**
     Returns the date representations of existing TaskInstances that would be deleted given a new start date, end date, and set of DayPatterns for a recurring-type Task
     - parameter startDate: Newly proposed start date
     - parameter endDate: Newly proposed end date
     - parameter dayPatterns: Set of DayPatterns
     - returns: Array of Strings representing TaskInstances that would be deleted, sorted by date. The Strings represent the dates in "M-d-yyyy" format
     */
    func getDeltaInstancesRecurring(startDate: Date, endDate: Date, dayPatterns: Set<DayPattern>) throws -> [Date] {
        
        var datesDelta: [Date] = []
        
        guard let instances = self.instances as? Set<TaskInstance> else {
            let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesRecurring() could not retrieve instances as Set of TaskInstance"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        // Filter existing TaskInstances for ones before the proposed start date or after the proposed end date
        for instance in instances {
            guard let dateString = instance._date,
                  let date = SaveFormatter.storedStringToDate(dateString) else {
                let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesRecurring() found a TaskInstance with nil or invalid _date",
                                                "TaskInstance" : instance.debugDescription]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
            }
            
            if date.lessThanDate(startDate) || endDate.lessThanDate(date) {
                datesDelta.append(date)
            }
        }
        
        // Loop through each of the days from startDate to endDate to evaluate if TaskInstances for each day would be created, deleted, or carried over
        var dateCounter = startDate
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            /*
             Loop through the set of DayPatterns
             If one of the DayPatterns intersects with dateCounter's current Date, this Date is ignored and the next Date is checked, since the TaskInstance would be created or carried over.
             */
            for pattern in dayPatterns {
                switch pattern.type {
                case .dow:
                    if pattern.daysOfWeek.contains(Int16(Calendar.current.component(.weekday, from: dateCounter))) { matched = true }
                    break
                case .wom:
                    let day = Int16(Calendar.current.component(.day, from: dateCounter))
                    guard let daysInMonth = Calendar.current.range(of: .day, in: .month, for: dateCounter) else {
                        let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesRecurring() received nil days in month while iterating from startDate to endDate",
                                                        "dateCounter" : dateCounter.debugDescription]
                        throw ErrorManager.recordNonFatal(.dateOperationFailed, self.mergeDebugDictionary(userInfo: userInfo))
                    }
                    
                    if pattern.daysOfWeek.contains(Int16(Calendar.current.component(.weekday, from: dateCounter))) {
                        if pattern.weeksOfMonth.contains(Int16(ceil(Float(day)/7))) { matched = true }
                        else if pattern.weeksOfMonth.contains(SaveFormatter.weekOfMonthToStored(.last)) {
                            if day + 7 > daysInMonth.count { matched = true }
                        }
                    }
                    break
                case .dom:
                    /*
                     Last day of month is represented as 0, so the following conditions are checked
                     - The DayPattern's selected days of month are checked for equality to dateCounter's day, OR
                     - The DayPattern's selected days of month contains 0 and dateCounter is the last day of the month
                     */
                    if pattern.daysOfMonth.contains(Int16(Calendar.current.component(.day, from: dateCounter))) { matched = true }
                    else if pattern.daysOfMonth.contains(0) && Calendar.current.component(.day, from: dateCounter) == Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count { matched = true }
                    break
                }
                
                if matched { break }
            }
            
            // If none of the proposed DayPatterns matched with the date and a TaskInstance already exists for that date, add it to datesDelta since it would be deleted
            if !matched && instances.contains(where: { $0._date == SaveFormatter.dateToStoredString(dateCounter)}) {
                datesDelta.append(dateCounter)
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                let userInfo: [String : Any] = ["Message" : "Task.getDeltaInstancesRecurring() failed to increment dateCounter",
                                                "dateCounter" : dateCounter.debugDescription]
                throw ErrorManager.recordNonFatal(.dateOperationFailed, self.mergeDebugDictionary(userInfo: userInfo))
            }
            
            matched = false
            
        }
        
        return datesDelta.sorted()
    }
    
}

// MARK: - TaskInstance and TaskTargetSet updating

extension Task {
    
    /**
     For a specific-type Task, updates taskType, instances, and targetSets. This function
     - Updates this Task's taskType to .specific
     - Sets this Task's startDate and endDate to nil
     - Deletes all existing TaskTargetSets that are associated with this Task
     - Deletes existing TaskInstances that don't intersect with the caller-provided dates, and generates new TaskInstances and assigns them to this Task
     - parameter dates: Array of Dates to be assigned to this Task's instances
     */
    func updateSpecificInstances(dates: [Date]) throws {
        
        // Set task type, set start and end dates, and delete associated TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(.specific)
        self.startDate = nil
        self.endDate = nil
        if let targetSets = self.targetSets {
            // Delete TaskTargetSets (if any exist)
            for case let tts as TaskTargetSet in targetSets { CDCoordinator.moc.delete(tts) }
        }
        
        /*
         * Go through this Task's existing TaskInstances. Delete ones that don't intersect with new Dates, and make note of the ones that do so that those instances aren't re-generated
         */
        let newDatesStrings = Set(dates.map{ SaveFormatter.dateToStoredString($0) })
        var datesToBeAdded: Set<String> = newDatesStrings
        guard let existingInstances = self.instances as? Set<TaskInstance> else {
            let userInfo: [String : Any] = ["Message" : "Task.updateSpecificInstances() could not retrieve instances as Set of TaskInstance"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        for existingInstance in existingInstances {
            
            guard let existingDate = existingInstance._date else {
                let userInfo: [String : Any] = ["Message" : "Task.updateSpecificInstances() found nil in a TaskInstance's _date",
                                                "TaskInstance" : existingInstance.debugDescription]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
            }
            
            if !newDatesStrings.contains(existingDate) {
                CDCoordinator.moc.delete(existingInstance)
            } else {
                datesToBeAdded.remove(existingDate)
            }
            
        }
        
        // Generate TaskInstances for the remaining dates that don't already exist for this Task
        for date in datesToBeAdded {
            self.addToInstances(TaskInstance(entity: TaskInstance.entity(), insertInto: CDCoordinator.moc, date: date))
        }
        
    }
    
    /**
     For a recurring-type Task, updates dates, taskType, instances, and targetSets. This function
     - Updates this Task's taskType to .recurring
     - Sets this Task's startDate and endDate
     - Generates new TaskInstances where needed, and deletes existing TaskInstances that don't intersect with the caller-provided TaskTargetSets
     - parameter startDate: startDate to assign to this Task
     - parameter endDate: endDate to assign to this Task
     */
    func updateRecurringInstances(startDate: Date, endDate: Date) throws {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(.recurring)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        
        do {
            try generateAndPruneInstances()
        } catch (let error) {
            throw error
        }
        
    }
    
    /**
     For a recurring-type Task, updates dates, taskType, instances, and targetSets. This function
     - Updates this Task's taskType to .recurring
     - Sets this Task's startDate and endDate
     - Deletes existing TaskTargetSets
     - Sets new TaskTargetSets and generates new TaskInstances where needed, and deletes existing TaskInstances that don't intersect with the caller-provided TaskTargetSets
     - parameter startDate: startDate to assign to this Task
     - parameter endDate: endDate to assign to this Task
     - parameter targetSets: Set of new TaskTargetSets to associate with this Task
     */
    func updateRecurringInstances(startDate: Date, endDate: Date, targetSets: Set<TaskTargetSet>) throws {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(.recurring)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        if let existingTargetSets = self.targetSets {
            for case let tts as TaskTargetSet in existingTargetSets {
                if !targetSets.contains(tts) {
                    CDCoordinator.moc.delete(tts)
                }
            }
        } else {
            let userInfo: [String : Any] = ["Message" : "Task.updateRecurringInstances() found nil in targetSets"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        // Set new targetSets and update instances
        self.targetSets = NSSet(set: targetSets)
        
        do {
            try generateAndPruneInstances()
        } catch (let error) {
            throw error
        }
        
    }
    
    /**
     Uses this Task's targetSets to generate new or attach existing TaskInstances. Existing TaskInstances that are no longer needed are deleted.
     */
    private func generateAndPruneInstances() throws {
        
        guard let sortedTargetSets = (self.targetSets as? Set<TaskTargetSet>)?.sorted(by: { $0._priority < $1._priority} ) else {
            let userInfo: [String : Any] = ["Message" : "Task.generateAndPruneInstances() could not read from or sort targetSets"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        guard let sd = self.startDate,
              let ed = self.endDate,
              var dateCounter = SaveFormatter.storedStringToDate(sd),
              let endDate = SaveFormatter.storedStringToDate(ed) else {
            let userInfo: [String : Any] = ["Message" : "Task.generateAndPruneInstances() found a nil or invalid startDate and/or endDate"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary(userInfo: userInfo))
        }
        
        var newInstances = Set<TaskInstance>()
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            for idx in 0 ..< sortedTargetSets.count {
                if try sortedTargetSets[idx].checkDay(day: Int16(Calendar.current.component(.day, from: dateCounter)),
                                                      weekday: Int16(Calendar.current.component(.weekday, from: dateCounter)),
                                                      daysInMonth: Int16( Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count ?? 0)) {
                    
                    // extractInstance will return a TaskInstance with the specified date - either an existing one that's been disassociated from this Task's instances or a new one in the MOC
                    let ti = extractInstance(date: SaveFormatter.dateToStoredString(dateCounter))
                    
                    newInstances.insert(ti)
                    ti.updateTargetSet(sortedTargetSets[idx])
                    
                    matched = true
                }
                if matched { matched = false; break}
                
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                let userInfo: [String : Any] = ["Message" : "Task.generateAndPruneInstances() failed to increment dateCounter",
                                                "dateCounter" : dateCounter.debugDescription]
                throw ErrorManager.recordNonFatal(.dateOperationFailed, self.mergeDebugDictionary(userInfo: userInfo))
            }
        }
        
        /*
         All TaskInstances that should have been migrated to the new set should have been done so by now.
         The old instances are deleted and self.instances is pointed to the new Set
         */
        if let instances = self.instances {
            for case let oldInstance as TaskInstance in instances {
                CDCoordinator.moc.delete(oldInstance)
            }
        }
        
        self.instances = NSSet(set: newInstances)
        
    }
    
    /**
     Unassociates (if necessary) and returns a TaskInstance with the desired date
     If one already exists and belongs to this Task, it is removed from instances; otherwise, a new one is created in the MOC
     - parameter date: The date that the returned TaskInstance should have
     - returns: TaskInstance with specified Date - either newly created or an existing one that's been disassociated with this Task
     */
    private func extractInstance(date: String) -> TaskInstance {
        if let instances = self.instances {
            for case let instance as TaskInstance in instances {
                if instance._date == date {
                    removeFromInstances(instance)
                    return instance
                }
            }
        }
        let instance = TaskInstance(entity: TaskInstance.entity(),
                                    insertInto: CDCoordinator.moc,
                                    date: date)
        return instance
    }
    
}
