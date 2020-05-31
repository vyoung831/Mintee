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
    
    // MARK: - Initializers
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     name: String,
                     tags: [String],
                     startDate: Date,
                     endDate: Date,
                     targetSets: [TaskTargetSet]) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        updateTags(newTagNames: tags)
        updateDates(startDate: startDate, endDate: endDate)
        setNewTargetSets(targetSets: targetSets)
    }
    
    // MARK: - Tag handling
    
    /**
     - returns: An array of strings representing the tagNames of this Task's tags
     */
    public func getTagNamesArray() -> [String] {
        if let tags = self.tags as? Set<Tag> {
            let tagNames = tags.map({$0.name ?? ""})
            return tagNames
        }
        return []
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
    
    // MARK: - Date handling
    
    /**
     Converts start and end dates to save format and stores them to this Task.
     This function does not check if startDate is before endDate; it should have been handled by the caller.
     - parameter startDate: Start date of type Date
     - parameter endDate: End date of type Date
     */
    func updateDates(startDate: Date, endDate: Date) {
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
    }
    
    // MARK: - TaskTargetSet and TaskInstance handling
    
    /**
     Adds TaskTargetSets to this Task and generates TaskInstances, adding those TaskInstances to this Task and the appropriate TaskTargetSet.
     This function expects startDate and endDate to already be non-nil when called
    - parameter targetSets: Array of TaskTargetSets to associate with this Task
    */
    private func setNewTargetSets(targetSets: [TaskTargetSet]) {
        
        self.addToTargetSets(NSSet(array: targetSets))
        let sortedTargetSets = targetSets.sorted(by: { $0.priority < $1.priority} )
        
        guard let sd = self.startDate, let ed = self.endDate else {
            print("setNewTargetSets was called but startDate and/or endDate were nil")
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
                
                let day = Calendar.current.component(.day, from: dateCounter)
                let weekday = Calendar.current.component(.weekday, from: dateCounter)
                if targetSet.checkDay(day: Int16(day), weekday: Int16(weekday)) {
                    
                    let ti = TaskInstance(context: CDCoordinator.moc)
                    ti.date = SaveFormatter.dateToStoredString(dateCounter)
                    
                    self.addToInstances(ti)
                    targetSet.addToInstances(ti)
                    
                    matched = true
                }
                
                // TaskInstance created; check next date
                if matched { matched = false; break}
                
            }
            
            // Increment day
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter) {
                dateCounter = newDate
            } else {
                print("An error occurred in setNewTargetSets() when incrementing dateCounter")
                exit(-1)
            }
        }
    }
    
    // MARK: - Deletion
    
    /**
     Disassociates all Tags from this Task, checks each Tag for deletion, and deletes this task from the shared MOC.
     Also deletes all TaskInstances and TaskTargetSets associated with this Task.
     */
    func deleteSelf() {
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
