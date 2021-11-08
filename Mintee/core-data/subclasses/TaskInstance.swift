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
    
    var _completion: Float { get { return self.completion } set { self.completion = newValue } }
    var _task: Task { get { return self.task } }
    var _targetSet: TaskTargetSet? { get { return self.targetSet } }
    
    var _date: Date {
        get throws {
            guard let formattedDate = SaveFormatter.storedStringToDate(self.date) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                  ["date": self.date])
            }
            return formattedDate
        }
    }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, date: String) {
        self.init(entity: entity, insertInto: context)
        self.date = date
    }
    
}

extension TaskInstance {
    
    func updateTargetSet(_ tts: TaskTargetSet) {
        self.targetSet = tts
    }
    
}
