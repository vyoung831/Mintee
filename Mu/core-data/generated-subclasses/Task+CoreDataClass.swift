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
                     taskTargetSetViews: [TaskTargetSetView]) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        updateTags(newTagNames: tags)
        updateDates(startDate: startDate, endDate: endDate)
        setNewDatesAndTaskTargetSets(startDate: startDate,
                                     endDate: endDate,
                                     taskTargetSetViews: taskTargetSetViews)
    }
    
    
    // MARK: - Date handling
    
    /**
     Converts start and end dates to save format and stores them to this Task
     - parameter startDate: Start date of type Date
     - parameter endDate: End date of type Date
     */
    func updateDates(startDate: Date, endDate: Date) {
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
    }
    
    // MARK: - TaskTargetSet handling
    
    /**
     Sets startDate and endDate for this task, as well as generates TaskTargetSets and TaskInstances to add to targetSets and instances, respectively.
     This function does not check if startDate is before endDate; it should have been handled by the view calling this function.
     - parameter startDate: new startDate to set for Task
     - parameter endDate: new endDate to set for Task
     - parameter taskTargetSetViews: Array of TaskTargetSetViews, ordered in ascending priority
     */
    private func setNewDatesAndTaskTargetSets(startDate: Date, endDate: Date, taskTargetSetViews: [TaskTargetSetView]) {
        
        updateDates(startDate: startDate, endDate: endDate)
        
        // Loop through the array of TaskTargetSetView and create TaskTargetSet for each
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
        generateNewTaskInstances(startDate: startDate, endDate: endDate, taskTargetSetViews: taskTargetSetViews)
    }
    
    // MARK: - TaskInstance handling
    
    /**
     Generates TaskInstances for a newTask.
     - parameter startDate: New Task's startDate
     - parameter endDate: New Task's startDate
     - parameter taskTargetSetViews: Array of TaskTargetSetViews, ordered in ascending priority
     */
    private func generateNewTaskInstances(startDate: Date, endDate: Date, taskTargetSetViews: [TaskTargetSetView]) {
        
        // To cut down on unwrapping, create an array of TaskTargetSetRepresentations, mapped from taskTargetSetViews
        let reps = taskTargetSetViews.map({ targetSetView in
            // Days of month nil coalesced to 0. Should never be a String that can't be converted to Int
            TaskTargetSetRepresentation(daysOfWeek: Set(targetSetView.selectedDaysOfWeek.map{ SaveFormatter.getWeekdayNumber(weekday: $0) }),
                                        weeksOfMonth: Set(targetSetView.selectedWeeksOfMonth.map{ Int16($0) }),
                                        daysOfMonth: Set(targetSetView.selectedDaysOfMonth.map{ Int16($0) ?? 0 }))
        })
        
        // Loop through each of the days from startDate to endDate and generate TaskInstances where necessary
        var dateCounter = startDate
        var matched = false
        while dateCounter.lessThanOrEqualToDate(endDate) {
            
            /*
             Loop through the array of TaskTargetSetRepresentations (already sorted by priority).
             If one of the representations's selected days/weekdays/weeks intersects with current dateCounter, a TaskInstance is created and added to instances.
             Since this is for new Tasks, prior task existence is not checked.
             */
            for targetSetRep in reps {
                switch targetSetRep.type{
                case .dow:
                    if targetSetRep.checkDayOfWeek(weekday: Calendar.current.component(.weekday, from: dateCounter)) {
                        addInstance(date: dateCounter)
                        matched = true
                    }; break
                case .wom:
                    if targetSetRep.checkWeekdayOfMonth(day: Calendar.current.component(.day, from: dateCounter),
                                                        weekday: Calendar.current.component(.weekday, from: dateCounter)) {
                        addInstance(date: dateCounter)
                        matched = true
                    }; break
                case .dom:
                    if targetSetRep.checkDayOfMonth(day: Calendar.current.component(.day, from: dateCounter)) {
                        addInstance(date: dateCounter)
                        matched = true
                    }; break
                }
                // If a TaskTargetSetRepresentation matched with the current dateCounter, exit and check the next day
                if matched { matched = false ; break }
            }
            // Increment day
            dateCounter = Calendar.current.date(byAdding: .day, value: 1, to: dateCounter)!
        }
    }
    
    /**
     Creates a TaskInstance with the date provided and adds to instances
     - parameter date: Date to be converted to String and saved to the TaskInstance
     */
    private func addInstance(date: Date) {
        addToInstances(TaskInstance(entity: TaskInstance.entity(),
                                    insertInto: CDCoordinator.moc,
                                    date: SaveFormatter.dateToStoredString(date)))
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
