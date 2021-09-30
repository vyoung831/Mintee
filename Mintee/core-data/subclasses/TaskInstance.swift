//
//  TaskInstance+CoreDataClass.swift
//  Mintee
//
//  Created by Vincent Young on 5/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData
import EventKit

@objc(TaskInstance)
public class TaskInstance: NSManagedObject {
    
    @NSManaged private var date: String
    @NSManaged private var completion: Float
    @NSManaged private var task: Task
    @NSManaged private var targetSet: TaskTargetSet?
    @NSManaged private var ekEvent: String?
    @NSManaged private var ekReminder: String?
    @NSManaged private var lastModify: Date
    
    var _date: String { get { return self.date } }
    var _completion: Float { get { return self.completion } }
    var _task: Task { get { return self.task } }
    var _targetSet: TaskTargetSet? { get { return self.targetSet } }
    var _ekEvent: String? { get { return self.ekEvent } }
    var _ekReminder: String? { get { return self.ekReminder } }
    var _lastModify: Date { get { return self.lastModify } }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, date: String) {
        self.init(entity: entity, insertInto: context)
        self.date = date
        self.lastModify = Date()
    }
    
}

extension TaskInstance {
    
    func updateCompletion(_ completion: Float) {
        self.completion = completion
        self.lastModify = Date()
    }
    
    func updateEKEvent(_ identifier: String) {
        self.ekEvent = identifier
    }
    
    func updateEKReminder(_ identifier: String) {
        self.ekReminder = identifier
    }
    
    func updateTargetSet(_ tts: TaskTargetSet) {
        self.targetSet = tts
    }
    
}

extension TaskInstance {
    
    /**
     Syncs this TaskInstance's completion data with that of an EKReminder.
     If the completion data is different, the last-modified dates of this and the provided EKReminder are compared.
     The completion value from the later-modified object is copied into the other object.
     - parameter reminder: The EKReminder for which to sync this TaskInstance's data with.
     - returns: True if there was a change made to the EKReminder or this TaskInstance.
     */
    func syncWithReminder(_ reminder: EKReminder) -> Bool {
        
        var different: Bool = false
        
        // Only compare last-modified dates if completion data is not in-sync
        if (self._completion <= 0 && reminder.isCompleted) || (self._completion > 0 && !reminder.isCompleted) {
            if let reminderLastModify = reminder.lastModifiedDate {
                if self._lastModify.lessThan(reminderLastModify) {
                    self.updateCompletion(reminder.isCompleted ? 1 : 0)
                    different = true
                } else {
                    reminder.isCompleted = self._completion > 0
                    different = true
                }
            } else {
                // Reminder was never modified. Copy this TaskInstance's completion data to Reminder.
                reminder.isCompleted = self.completion > 0
                different = true
            }
        }
        
        if (self.task._name != reminder.title) {
            reminder.title = self.task._name
            different = true
        }
        
        return different
    }
    
}
