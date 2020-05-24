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
    
    // MARK: - TaskTargetSet handling
    
    /**
     Creates new TaskTargetSets and adds them to the targetSets relationship
     - parameter taskTargetSetViews: Array of TaskTargetSetViews, ordered in ascending priority
     */
    func setNewTaskTargetSets(taskTargetSetViews: [TaskTargetSetView]) {
        for i in 0 ... taskTargetSetViews.count - 1 {
            let ttsv = taskTargetSetViews[i]
            let tts = TaskTargetSet(context: CDCoordinator.moc)
            
            // Create instances of DayOfWeek, WeekOfMonth, and DayOfMonth and add them to the TaskTargetSet's relationships
            if ttsv.selectedDaysOfWeek.count > 0 {
                
                for dow in ttsv.selectedDaysOfWeek {
                    let dayOfWeek = DayOfWeek(context: CDCoordinator.moc)
                    dayOfWeek.day = SaveFormatter.getWeekdayNumber(weekday: dow)
                    tts.addToDaysOfWeek(dayOfWeek)
                }
                
                if ttsv.selectedWeeksOfMonth.count > 0 {
                    for wom in ttsv.selectedWeeksOfMonth {
                        let weekOfMonth = WeekOfMonth(context: CDCoordinator.moc)
                        weekOfMonth.week = Int16(wom)
                        tts.addToWeeksOfMonth(weekOfMonth)
                    }
                }
                
            } else {
                for day in ttsv.selectedDaysOfMonth {
                    let dayOfMonth = DayOfMonth(context: CDCoordinator.moc)
                    dayOfMonth.day = Int16(day) ?? 0
                    tts.addToDaysOfMonth(dayOfMonth)
                }
            }
            
            tts.priority = Int16(i)
            self.addToTargetSets(tts)
        }
    }
    
    // MARK: - TaskInstance and date handling
    
    /**
     Updates the Task's startDate and endDate. This function does not check the if startDate is before endDate, as it should have been handled before calling this function.
     - Parameters:
       - startDate: new startDate to set for Task
       - endDate: new endDate to set for Task
     */
    public func updateDates(startDate: String, endDate: String) {
        self.startDate = startDate
        self.endDate = endDate
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
    
    // MARK: - Deletion
    
    /**
     Disassociates all Tags from this Task, checks each Tag for deletion, and deletes this task from the shared MOC
     */
    func deleteSelf() {
        self.removeAllTags()
        CDCoordinator.moc.delete(self)
    }
    
}
