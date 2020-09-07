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
            print("Error deleting TaskTargetSets and TaskInstances from \(self.debugDescription)")
            exit(-1)
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
                    print("Error: tagName found with tagName = nil")
                    exit(-1)
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

// MARK: - TaskTargetSet and TaskInstance adding

extension Task {
    
    /**
     For a newly added recurring-type Task, adds TaskTargetSets and generates TaskInstances, associating those TaskInstances with this Task and the appropriate TaskTargetSet.
     - parameter startDate: Task's start date
     - parameter endDate: Task's end date
     - parameter targetSets: Set of TaskTargetSets to associate with this Task
     */
    private func newRecurringInstances(startDate: Date, endDate: Date, targetSets: Set<TaskTargetSet>) {
        
        // Set task type, start date, end date, and sort TaskTargetSets
        self.taskType = SaveFormatter.taskTypeToStored(type: .recurring)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        self.addToTargetSets(NSSet(set: targetSets))
        let sortedTargetSets = targetSets.sorted(by: { $0.priority < $1.priority} )
        
        // Gt start date and end date to iterate over
        guard let sd = self.startDate, let ed = self.endDate else {
            print("newRecurringInstances() was called but startDate and/or endDate were nil")
            exit(-1)
        }
        var dateCounter = SaveFormatter.storedStringToDate(sd)
        let endDate = SaveFormatter.storedStringToDate(ed)
        
        // Loop through each of the days from startDate to endDate and generate TaskInstances where necessary
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            /*
             Loop through the array of TaskTargetSets (already sorted by priority).
             If one of the TaskTargetSet's pattern intersects with current dateCounter, a TaskInstance is created, added to instances, and associated with the TaskTargetSet.
             Since this is for new Tasks, prior task existence is not checked.
             */
            for targetSet in sortedTargetSets {
                
                if targetSet.checkDay(day: Int16(Calendar.current.component(.day, from: dateCounter)),
                                      weekday: Int16(Calendar.current.component(.weekday, from: dateCounter)),
                                      daysInMonth: Int16( Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count ?? 0)) {
                    
                    let ti = TaskInstance(context: CDCoordinator.moc)
                    ti.date = SaveFormatter.dateToStoredString(dateCounter)
                    
                    self.addToInstances(ti)
                    targetSet.addToInstances(ti)
                    
                    matched = true
                }
                
                // TaskInstance created; check next date
                if matched { matched = false; break }
                
            }
            
            // Increment day
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                print("An error occurred in newRecurringInstances() when incrementing dateCounter")
                exit(-1)
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
            print("getdeltainstancesspecific() in Task could not retrieve existing instances"); exit(-1)
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
            print("getDeltaInstancesRecurring() in Task could not retrieve existing instances"); exit(-1)
        }
        
        // Filter existing TaskInstances for ones before the proposed start date
        let instancesBefore = instances.filter({
            if let date = $0.date {
                return SaveFormatter.storedStringToDate(date).lessThanDate(startDate)
            } else { print("getDeltaInstancesRecurring() found an existing TaskInstance with a nil date value"); exit(-1) }
        })
        
        // Filter existing TaskInstances for ones after the proposed end date
        let instancesAfter = instances.filter({
            if let date = $0.date {
                return endDate.lessThanDate(SaveFormatter.storedStringToDate(date))
            } else { print("getDeltaInstancesRecurring() found an existing TaskInstance with a nil date value"); exit(-1) }
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
                    guard let daysInMonth = Calendar.current.range(of: .day, in: .month, for: dateCounter) else { exit(-1) }
                    
                    if pattern.daysOfWeek.contains(Int16(Calendar.current.component(.weekday, from: dateCounter))) {
                        if pattern.weeksOfMonth.contains(Int16(ceil(Float(day)/7))) { matched = true }
                        else if pattern.weeksOfMonth.contains(SaveFormatter.getWeekOfMonthNumber(wom: "Last")) {
                            if day + 7 > daysInMonth.count { matched = true }
                        }
                    }
                    break
                case .dom:
                    if pattern.daysOfMonth.contains(Int16(Calendar.current.component(.day, from: dateCounter))) { matched = true }
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
            } else { print("An error occurred in getDeltaInstancesRecurring() when incrementing dateCounter"); exit(-1) }
            
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
        guard let existingInstances = self.instances as? Set<TaskInstance> else { exit(-1) }
        for existingInstance in existingInstances {
            if let existingDate = existingInstance.date {
                if !newDatesStrings.contains(existingDate) {
                    CDCoordinator.moc.delete(existingInstance)
                } else {
                    datesToBeAdded.remove(existingDate)
                }
            }
            else { exit(-1) }
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
            print("Error deleting TaskTargetSets from \(self.debugDescription)")
            exit(-1)
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
            print("updateInstances() call from \(self.debugDescription) could not get and sort targetSets")
            exit(-1)
        }
        
        guard let sd = self.startDate, let ed = self.endDate else {
            print("setNewTargetSets was called but startDate and/or endDate were nil")
            exit(-1)
        }
        
        var newInstances = Set<TaskInstance>()
        var dateCounter = SaveFormatter.storedStringToDate(sd)
        let endDate = SaveFormatter.storedStringToDate(ed)
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            for case let targetSet in sortedTargetSets {
                if targetSet.checkDay(day: Int16(Calendar.current.component(.day, from: dateCounter)),
                                      weekday: Int16(Calendar.current.component(.weekday, from: dateCounter)),
                                      daysInMonth: Int16( Calendar.current.range(of: .day, in: .month, for: dateCounter)?.count ?? 0)) {
                    
                    // extractInstance will return a TaskInstance with the specified date - either an existing one that's been disassociated from its TaskTargetSet or a new one in the MOC
                    let ti = extractInstance(date: SaveFormatter.dateToStoredString(dateCounter))
                    newInstances.insert(ti)
                    ti.targetSet = targetSet
                    
                    matched = true
                }
                if matched { matched = false; break}
                
            }
            
            // Increment dateCounter
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else { print("An error occurred in setNewTargetSets() when incrementing dateCounter"); exit(-1) }
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
     Unassociates (if necessary) and returns a TaskInstance with the desired date. This function was created for TaskInstances that need to have their targetSet relationship updated
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
