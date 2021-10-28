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
    
    @NSManaged private var name: String
    @NSManaged private var taskType: Int16
    @NSManaged private var startDate: String?
    @NSManaged private var endDate: String?
    @NSManaged private var taskSummaryAnalysis: TaskSummaryAnalysis
    @NSManaged private var instances: NSSet?
    @NSManaged private var tags: NSSet?
    @NSManaged private var targetSets: NSSet?
    
    var _name: String { get { return self.name } set { self.name = newValue } }
    var _taskSummaryAnalysis: TaskSummaryAnalysis { get { return self.taskSummaryAnalysis } }
    
    var _taskType: SaveFormatter.taskType {
        get throws {
            guard let formatted_type = SaveFormatter.taskType.init(rawValue: self.taskType) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return formatted_type
        }
    }
    
    var _startDate: Date? {
        get throws {
            guard let startDateString = self.startDate else { return nil }
            guard let formattedDate = SaveFormatter.storedStringToDate(startDateString) else {
                if (try self._taskType) == .recurring {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return formattedDate
        }
    }
    
    var _endDate: Date? {
        get throws {
            guard let endDateString = self.endDate else {
                if (try self._taskType) == .recurring {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                return nil
            }
            guard let formattedDate = SaveFormatter.storedStringToDate(endDateString) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return formattedDate
        }
    }
    
    var _instances: Set<TaskInstance> {
        get throws {
            guard let unwrappedSet = self.instances else {
                if (try self._taskType) == .specific {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                return Set()
            }
            guard let castedSet = unwrappedSet as? Set<TaskInstance> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return castedSet
        }
    }
    
    var _tags: Set<Tag> {
        get throws {
            guard let unwrappedSet = self.tags else { return Set() }
            guard let castedSet = unwrappedSet as? Set<Tag> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return castedSet
        }
    }
    
    var _targetSets: Set<TaskTargetSet> {
        get throws {
            guard let unwrappedSet = self.targetSets else {
                if (try self._taskType) == .recurring {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                return Set()
            }
            guard let castedSet = unwrappedSet as? Set<TaskTargetSet> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return castedSet
        }
    }
    
    /**
     Convenience init for recurring-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext,
                     name: String,
                     tags: Set<String>,
                     startDate: Date,
                     endDate: Date,
                     targetSets: Set<TaskTargetSet>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        try self.updateTags(newTagNames: tags, context)
        try self.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: targetSets, context)
    }
    
    /**
     Convenience init for specific-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext,
                     name: String,
                     tags: Set<String>,
                     dates: [Date]) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        try self.updateTags(newTagNames: tags, context)
        try self.updateSpecificInstances(dates: dates, context)
    }
    
    /**
     Disassociates all Tags from this Task, checks each Tag for deletion, and deletes this task from the shared MOC.
     Also deletes all TaskInstances and TaskTargetSets associated with this Task.
     - parameter moc: The MOC perform Task deletion and relationship cleanup in.
     */
    public func deleteSelf(_ moc: NSManagedObjectContext) throws {
        try self.removeAllTags(moc)
        
        if let targetSets = self.targetSets,
           let instances = self.instances {
            for case let tts as TaskTargetSet in targetSets { moc.delete(tts) }
            for case let ti as TaskInstance in instances { moc.delete(ti) }
        } else {
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        moc.delete(self)
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
     - returns: Dictionary containing existing debug info and debug descriptions of this Task and its TaskTargetSets
     */
    func mergeDebugDictionary() -> [String: Any] {
        var userInfo: [String: Any] = [:]
        let prefix = "Task."
        userInfo["\(prefix)debugDescription"] = self.debugDescription
        if let ttsArray = self.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                let ttsPrefix = "\(prefix)TTS[\(idx)]"
                let patternPrefix = "\(ttsPrefix)._pattern"
                let pattern = ttsArray[idx]._pattern
                
                userInfo["\(ttsPrefix).debugDescription"] = ttsArray[idx].debugDescription
                pattern.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(patternPrefix).")
            }
        }
        return userInfo
    }
    
    /**
     Gathers debug descriptions of this Task and its TaskTargetSets.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info
     - parameter prefix: String to be prepended to keys that this function adds to `userInfo`.
     - returns: Dictionary containing existing debug info and debug descriptions of this Task and its TaskTargetSets
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        userInfo["\(prefix)debugDescription"] = self.debugDescription
        if let ttsArray = self.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                let ttsPrefix = "\(prefix)TTS[\(idx)]"
                let patternPrefix = "\(ttsPrefix)._pattern"
                let pattern = ttsArray[idx]._pattern

                userInfo["\(ttsPrefix).debugDescription"] = ttsArray[idx].debugDescription
                pattern.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(patternPrefix).")
            }
        }
    }
    
}


// MARK: - Tag handling

extension Task {
    
    /**
     Updates this Task's tags relationship to contain only the Tags passed in.
     Tags that were already associated with this Task but that don't exist in the new tags passed in are un-associated and checked for possible deletion.
     - parameter newTagNames: Set of names of Tags to set as this Task's tags.
     - parameter moc: The MOC to update this Task's Tags in.
     */
    public func updateTags(newTagNames: Set<String>,_ moc: NSManagedObjectContext) throws {
        // Remove unrelated tags and check for deletion
        try self.removeUnrelatedTags(newTagNames: newTagNames, moc)
        try Tag.associateTags(tagNames: newTagNames, self, moc)
    }
    
    /**
     Removes Tags that are no longer to be associated with this Task.
     Tags that were already associated with this Task but that don't exist in the new tags passed in are un-associated and checked for possible deletion.
     - parameter newTagNames: Set of names of Tags to set as this Task's tags.
     - parameter moc: The MOC in which to unassociate Tags from this Task.
     */
    private func removeUnrelatedTags(newTagNames: Set<String>,_ moc: NSManagedObjectContext) throws {
        if let existingTags = self.tags as? Set<Tag> {
            for tag in existingTags {
                if !newTagNames.contains(tag._name) {
                    self.removeFromTags(tag)
                    if try tag._tasks.count == 0 {
                        moc.delete(tag)
                    }
                }
            }
        }
    }
    
    /**
     Removes all Tags from this Task's tags relationship and checks each one of them for deletion.
     - parameter moc: The MOC in which to disassociate Tags from this Task.
     */
    private func removeAllTags(_ moc: NSManagedObjectContext) throws {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                self.removeFromTags(tag)
                if try tag._tasks.count == 0 {
                    moc.delete(tag)
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
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        var datesDelta: [String] = []
        for instance in instances {
            let date = try instance._date
            dates.contains(date) ? datesDelta.append(Date.toMDYPresent(date)) : nil
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
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        // Filter existing TaskInstances for ones before the proposed start date or after the proposed end date
        for instance in instances {
            let date = try instance._date
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
                    matched = try pattern.check_dayOfWeek(dateCounter)
                    break
                case .wom:
                    let day = Int16(Calendar.current.component(.day, from: dateCounter))
                    guard let daysInMonth = Calendar.current.range(of: .day, in: .month, for: dateCounter) else {
                        var userInfo: [String : Any] = ["dateCounter" : dateCounter.debugDescription]
                        self.mergeDebugDictionary(userInfo: &userInfo)
                        throw ErrorManager.recordNonFatal(.dateOperationFailed, userInfo)
                    }
                    
                    if try pattern.check_dayOfWeek(dateCounter) {
                        if try pattern.check_weekOfMonth(dateCounter, Int16(ceil(Float(day)/7))) {
                            matched = true
                        } else if pattern.weeksOfMonth.contains(.last) {
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
                    if try pattern.check_dayOfMonth(dateCounter) {
                        matched = true
                    } else if pattern.daysOfMonth.contains(.last) && Calendar.current.component(.day, from: dateCounter) == Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count {
                        matched = true
                    }
                    break
                }
                
                if matched { break }
            }
            
            // If none of the proposed DayPatterns matched with the date and a TaskInstance already exists for that date, add it to datesDelta since it would be deleted
            if try instances.contains(where: {try $0._date.equalToDate(dateCounter)}) && !matched {
                datesDelta.append(dateCounter)
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                var userInfo: [String : Any] = ["dateCounter" : dateCounter.debugDescription]
                self.mergeDebugDictionary(userInfo: &userInfo)
                throw ErrorManager.recordNonFatal(.dateOperationFailed, userInfo)
            }
            
            matched = false
            
        }
        
        return datesDelta.sorted()
    }
    
}

// MARK: - TaskInstance and TaskTargetSet updating

extension Task {
    
    /**
     For a specific-type Task, updates taskType, instances, and targetSets. This function does the following:
     - Updates this Task's taskType to `.specific`.
     - Sets this Task's startDate and endDate to nil.
     - Deletes all existing TaskTargetSets that are associated with this Task.
     - Deletes existing TaskInstances that don't intersect with the caller-provided dates, and generates new TaskInstances and assigns them to this Task.
     - parameter dates: Array of Dates to be assigned to this Task's instances.
     - parameter moc: The MOC in which to perform updates.
     */
    func updateSpecificInstances(dates: [Date],_ moc: NSManagedObjectContext) throws {
        
        // Set task type, set start and end dates, and delete associated TaskTargetSets
        self.taskType = SaveFormatter.taskType.specific.rawValue
        self.startDate = nil
        self.endDate = nil
        if let targetSets = self.targetSets {
            // Delete TaskTargetSets (if any exist)
            for case let tts as TaskTargetSet in targetSets { moc.delete(tts) }
        }
        
        // This Task's existing TaskInstances are iterated through. Ones that don't intersect with new Dates are deleted and save others so they aren't regenerated
        var newDates = Set(dates)
        guard let existingInstances = self.instances as? Set<TaskInstance> else {
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        for existingInstance in existingInstances {
            if !dates.contains(try existingInstance._date) {
                moc.delete(existingInstance)
            } else {
                newDates.remove(try existingInstance._date)
            }
        }
        
        // Generate TaskInstances for the remaining dates that don't already exist for this Task
        for date in newDates {
            self.addToInstances(TaskInstance(entity: TaskInstance.entity(), insertInto: moc, date: SaveFormatter.dateToStoredString(date)))
        }
        
    }
    
    /**
     For a recurring-type Task, updates dates, taskType, instances, and targetSets. This function
     - Updates this Task's taskType to .recurring
     - Sets this Task's startDate and endDate
     - Generates new TaskInstances where needed, and deletes existing TaskInstances that don't intersect with the caller-provided TaskTargetSets
     - parameter startDate: startDate to assign to this Task
     - parameter endDate: endDate to assign to this Task
     - parameter moc: The MOC in which to perform updates.
     */
    func updateRecurringInstances(startDate: Date, endDate: Date,_ moc: NSManagedObjectContext) throws {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskType.recurring.rawValue
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        
        do {
            try generateAndPruneInstances(moc)
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
     - parameter moc: The MOC in which to perform updates.
     */
    func updateRecurringInstances(startDate: Date, endDate: Date, targetSets: Set<TaskTargetSet>,_ moc: NSManagedObjectContext) throws {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskType.recurring.rawValue
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        if let existingTargetSets = self.targetSets {
            for case let tts as TaskTargetSet in existingTargetSets {
                if !targetSets.contains(tts) {
                    moc.delete(tts)
                }
            }
        } else {
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        // Set new targetSets and update instances
        self.targetSets = NSSet(set: targetSets)
        
        do {
            try generateAndPruneInstances(moc)
        } catch (let error) {
            throw error
        }
        
    }
    
    /**
     Uses this Task's targetSets to generate new or attach existing TaskInstances. Existing TaskInstances that are no longer needed are deleted.
     - parameter moc: The MOC in which to perform updates.
     */
    private func generateAndPruneInstances(_ moc: NSManagedObjectContext) throws {
        
        guard let sortedTargetSets = (self.targetSets as? Set<TaskTargetSet>)?.sorted(by: { $0._priority < $1._priority} ) else {
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        guard let sd = self.startDate,
              let ed = self.endDate,
              var dateCounter = SaveFormatter.storedStringToDate(sd),
              let endDate = SaveFormatter.storedStringToDate(ed) else {
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
        }
        
        var newInstances = Set<TaskInstance>()
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            for idx in 0 ..< sortedTargetSets.count {
                if try sortedTargetSets[idx].checkDay(day: Int16(Calendar.current.component(.day, from: dateCounter)),
                                                      weekday: Int16(Calendar.current.component(.weekday, from: dateCounter)),
                                                      daysInMonth: Int16( Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count ?? 0)) {
                    
                    // extractInstance will return a TaskInstance with the specified date - either an existing one that's been disassociated from this Task's instances or a new one in the MOC
                    let ti = try extractInstance(date: dateCounter, moc)
                    
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
                var userInfo: [String : Any] = ["dateCounter" : dateCounter.debugDescription]
                self.mergeDebugDictionary(userInfo: &userInfo)
                throw ErrorManager.recordNonFatal(.dateOperationFailed, userInfo)
            }
        }
        
        /*
         All TaskInstances that should have been migrated to the new set should have been done so by now.
         The old instances are deleted and self.instances is pointed to the new Set
         */
        if let instances = self.instances {
            for case let oldInstance as TaskInstance in instances {
                moc.delete(oldInstance)
            }
        }
        
        self.instances = NSSet(set: newInstances)
        
    }
    
    /**
     Unassociates (if necessary) and returns a TaskInstance with the desired date
     If one already exists and belongs to this Task, it is removed from instances; otherwise, a new one is created in the MOC
     - parameter date: The date that the returned TaskInstance should have
     - returns: TaskInstance with specified Date - either newly created or an existing one that's been disassociated with this Task
     - parameter moc: The MOC in which to perform updates.
     */
    private func extractInstance(date: Date,_ moc: NSManagedObjectContext) throws -> TaskInstance {
        if let instances = self.instances {
            for case let instance as TaskInstance in instances {
                if try instance._date.equalToDate(date) {
                    removeFromInstances(instance)
                    return instance
                }
            }
        }
        return TaskInstance(entity: TaskInstance.entity(), insertInto: moc, date: SaveFormatter.dateToStoredString(date))
    }
    
}
