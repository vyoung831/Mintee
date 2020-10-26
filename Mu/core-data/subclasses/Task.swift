//
//  Task+CoreDataClass.swift
//  Mu
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
    
    /**
     Convenience init for recurring-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     name: String,
                     tags: [String],
                     startDate: Date,
                     endDate: Date,
                     targetSets: Set<TaskTargetSet>) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.updateTags(newTagNames: tags)
        self.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: targetSets)
    }
    
    /**
     Convenience init for specific-type Task
     */
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     name: String,
                     tags: [String],
                     dates: [Date]) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.updateTags(newTagNames: tags)
        self.updateSpecificInstances(dates: dates)
    }
    
    /**
     Disassociates all Tags from this Task, checks each Tag for deletion, and deletes this task from the shared MOC.
     Also deletes all TaskInstances and TaskTargetSets associated with this Task.
     */
    public func deleteSelf() {
        self.removeAllTags()
        
        if let targetSets = self.targetSets, let instances = self.instances {
            for case let tts as TaskTargetSet in targetSets { CDCoordinator.moc.delete(tts) }
            for case let ti as TaskInstance in instances { CDCoordinator.moc.delete(ti) }
        } else {
            Crashlytics.crashlytics().log("deleteSelf() in Task found targetSets and/or instances to be nil")
            fatalError()
        }
        
        CDCoordinator.moc.delete(self)
    }
    
}

// MARK: - Tag handling

extension Task {
    
    /**
     - returns: An array of strings representing the tagNames of this Task's tags
     */
    public func getTagNames() -> Set<String> {
        if let tags = self.tags as? Set<Tag> {
            let tagNames = Set(tags.map({$0.name ?? ""}))
            return tagNames
        }
        return Set<String>()
    }
    
    /**
     Takes an array of tag names and adds those as Tags to this Task's tags relationship. Of the tags passed in,
     - Unrelated Tags are removed and checked for deletion
     - New Tags that don't exist in the MOC are created
     - Existing Tags are added to this task's tags
     - parameter newTagNames: Array of tag names to associate with this Task
     */
    public func updateTags(newTagNames: [String]) {
        
        // Remove unrelated tags and check for deletion
        self.removeUnrelatedTags(newTagNames: newTagNames)
        
        for newTagName in newTagNames {
            self.addToTags(Tag.getOrCreateTag(tagName: newTagName))
        }
        
    }
    
    /**
     Takes in an array of tag names to associate with this Task and loops through the existing tags relationship
     Tags that are no longer to be associated are removed and checked for deletion
     - parameter newTagNames: Array of tag names to associate with this Task
     */
    private func removeUnrelatedTags(newTagNames: [String]) {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                
                guard let tagName = tag.name else {
                    Crashlytics.crashlytics().log("removeUnrelatedTags() in Task found tag with name = nil")
                    fatalError()
                }
                
                // If new tags don't contain an existing Tag's tagName, remove it from tags. After, if the Tag has no Tasks left, delete it
                if !newTagNames.contains(tagName) {
                    self.removeFromTags(tag)
                    if tag.tasks?.count == 0 {
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
                if tag.tasks?.count == 0 {
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
    func getDeltaInstancesSpecific(dates: Set<Date>) -> [String] {
        guard let instances = self.instances as? Set<TaskInstance> else {
            Crashlytics.crashlytics().log("getDeltaInstancesSpecific() in Task could not retrieve existing instances")
            fatalError()
        }
        
        var datesDelta: [String] = []
        let newDateStrings = dates.map{SaveFormatter.dateToStoredString($0)}
        for instance in instances {
            if let existingDate = instance.date {
                !newDateStrings.contains(existingDate) ? datesDelta.append(existingDate) : nil
            }
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
    func getDeltaInstancesRecurring(startDate: Date, endDate: Date, dayPatterns: Set<DayPattern>) -> [Date] {
        
        var datesDelta: [Date] = []
        
        guard let instances = self.instances as? Set<TaskInstance> else {
            Crashlytics.crashlytics().log("getDeltaInstancesRecurring() in Task could not retrieve existing instances")
            fatalError()
        }
        
        // Filter existing TaskInstances for ones before the proposed start date
        let instancesBefore = instances.filter({
            if let date = $0.date {
                return SaveFormatter.storedStringToDate(date).lessThanDate(startDate)
            } else {
                Crashlytics.crashlytics().log("getDeltaInstancesRecurring() found an existing TaskInstance with a nil date value")
                fatalError()
            }
        })
        
        // Filter existing TaskInstances for ones after the proposed end date
        let instancesAfter = instances.filter({
            if let date = $0.date {
                return endDate.lessThanDate(SaveFormatter.storedStringToDate(date))
            } else {
                Crashlytics.crashlytics().log("getDeltaInstancesRecurring() found an existing TaskInstance with a nil date value")
                fatalError()
            }
        })
        
        let beforeSorted = instancesBefore.map({ $0.date ?? "" }).sorted().map{ SaveFormatter.storedStringToDate($0) }
        let afterSorted = instancesAfter.map({ $0.date ?? "" }).sorted().map{ SaveFormatter.storedStringToDate($0) }
        datesDelta.append(contentsOf: beforeSorted)
        
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
                        Crashlytics.crashlytics().log("getDeltaInstancesRecurring() in Task found daysInMonth equal to nil in a Task of type .wom")
                        fatalError()
                    }
                    
                    if pattern.daysOfWeek.contains(Int16(Calendar.current.component(.weekday, from: dateCounter))) {
                        if pattern.weeksOfMonth.contains(Int16(ceil(Float(day)/7))) { matched = true }
                        else if pattern.weeksOfMonth.contains(SaveFormatter.getWeekOfMonthNumber(wom: "Last")) {
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
            if !matched && instances.contains(where: { $0.date == SaveFormatter.dateToStoredString(dateCounter)}) {
                datesDelta.append(dateCounter)
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                Crashlytics.crashlytics().log("An error occurred in getDeltaInstancesRecurring() when incrementing dateCounter")
                fatalError()
            }
            
            matched = false
            
        }
        
        datesDelta.append(contentsOf: afterSorted)
        return datesDelta
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
    func updateSpecificInstances(dates: [Date]) {
        
        // Set task type, set start and end dates, and delete associated TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(type: .specific)
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
            Crashlytics.crashlytics().log("updateSpecificInstances() in Task could not retrieve instances")
            fatalError()
        }
        for existingInstance in existingInstances {
            if let existingDate = existingInstance.date {
                if !newDatesStrings.contains(existingDate) {
                    CDCoordinator.moc.delete(existingInstance)
                } else {
                    datesToBeAdded.remove(existingDate)
                }
            }
            else {
                Crashlytics.crashlytics().log("updateSpecificInstances() in Task found a TaskInstance with nil date value")
                Crashlytics.crashlytics().setValue(existingInstance, forKey: "TaskInstance")
                fatalError()
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
    func updateRecurringInstances(startDate: Date, endDate: Date) {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(type: .recurring)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        generateAndPruneInstances()
        
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
    func updateRecurringInstances(startDate: Date, endDate: Date, targetSets: Set<TaskTargetSet>) {
        
        // Set task type, set start and end dates, and delete TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(type: .recurring)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        if let existingTargetSets = self.targetSets {
            for case let tts as TaskTargetSet in existingTargetSets {
                if !targetSets.contains(tts) {
                    CDCoordinator.moc.delete(tts)
                }
            }
        } else {
            Crashlytics.crashlytics().log("updateRecurringInstances() in Task failed to delete TaskTargetSets")
            fatalError()
        }
        
        // Set new targetSets and update instances
        self.targetSets = NSSet(set: targetSets)
        generateAndPruneInstances()
        
    }
    
    /**
     Uses this Task's targetSets to generate new or attach existing TaskInstances. Existing TaskInstances that are no longer needed are deleted.
     */
    private func generateAndPruneInstances() {
        
        guard let sortedTargetSets = (self.targetSets as? Set<TaskTargetSet>)?.sorted(by: { $0.priority < $1.priority} ) else {
            Crashlytics.crashlytics().log("generateAndPruneInstances() in Task failed to get and/or sort targetSets")
            fatalError()
        }
        
        guard let sd = self.startDate, let ed = self.endDate else {
            Crashlytics.crashlytics().log("generateAndPruneInstances was called but startDate and/or endDate were nil")
            fatalError()
        }
        var dateCounter = SaveFormatter.storedStringToDate(sd)
        let endDate = SaveFormatter.storedStringToDate(ed)
        
        var newInstances = Set<TaskInstance>()
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            for idx in 0 ..< sortedTargetSets.count {
                if sortedTargetSets[idx].checkDay(day: Int16(Calendar.current.component(.day, from: dateCounter)),
                                                  weekday: Int16(Calendar.current.component(.weekday, from: dateCounter)),
                                                  daysInMonth: Int16( Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count ?? 0)) {
                    
                    // extractInstance will return a TaskInstance with the specified date - either an existing one that's been disassociated from its TaskTargetSet or a new one in the MOC
                    let ti = extractInstance(date: SaveFormatter.dateToStoredString(dateCounter))
                    newInstances.insert(ti)
                    ti.targetSet = sortedTargetSets[idx]
                    
                    matched = true
                }
                if matched { matched = false; break}
                
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                Crashlytics.crashlytics().log("An error occurred in generateAndPruneInstances() when incrementing dateCounter")
                fatalError()
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
                if instance.date == date {
                    removeFromInstances(instance)
                    return instance
                }
            }
        }
        let instance = TaskInstance(context: CDCoordinator.moc)
        instance.date = date
        return instance
    }
    
}
