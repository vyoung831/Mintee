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

@objc(TaskInstance)
public class TaskInstance: NSManagedObject {
    
    @NSManaged private var date: String
    @NSManaged private var completion: Float
    @NSManaged private var task: Task
    @NSManaged private var targetSet: TaskTargetSet?
    @NSManaged private var ekEvent: String?
    @NSManaged private var ekReminder: String?
    @NSManaged private var lastModify: Date?
    
    var _date: String { get { return self.date } }
    var _completion: Float { get { return self.completion } }
    var _task: Task { get { return self.task } }
    var _targetSet: TaskTargetSet? { get { return self.targetSet } }
    var _ekEvent: String? { get { return self.ekEvent } }
    var _ekReminder: String? { get { return self.ekReminder } }
    var _lastModify: Date? { get { return self.lastModify } }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, date: String) {
        self.init(entity: entity, insertInto: context)
        self.date = date
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
