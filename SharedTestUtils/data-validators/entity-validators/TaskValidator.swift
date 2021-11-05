//
//  TaskValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TASK-1: A Task's taskType can only be one of the following values:
//      * `Recurring`
//      * `Specific`
//  (validated by getters)
//  - TASK-5: A Task's name is unique. (validated by MOC_Validator)
//  - TASK-7: A Task is associated with one and only one TaskSummaryAnalysis. (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 5/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskValidator {
    
    static var validators: [(Task) throws -> ()] = [
        TaskValidator.validateRecurringTask,
        TaskValidator.validateSpecificTask,
        TaskValidator.validateUniqueTaskInstanceDates,
        validateUniqueTTSPriorities
    ]
    
    static func validateTasks(_ tasks: Set<Task>) {
        for task in tasks {
            for validator in TaskValidator.validators {
                try! validator(task)
            }
        }
    }
    
    /**
     TASK-3: If a Task's taskType is `Recurring`, then its targetSets contains at least one TaskTargetSet.
     TASK-6: If a Task's taskType is `Recurring`, then its endDate is later than or equal to startDate.
     TI-2: If a TaskInstance's associated Task's taskType is `Recurring`, then the TaskInstance is associated with a TaskTargetSet.
     */
    static var validateRecurringTask: (Task) throws -> () = { task in
        if try task._taskType == .recurring {
            // TASK-6
            XCTAssert(try task._startDate!.lessThanOrEqualToDate(try task._endDate!))
            
            // TASK-3
            XCTAssert(try task._targetSets.count > 0)
            
            // TI-2
            for instance in try task._instances {
                XCTAssert(instance._targetSet != nil)
            }
        }
    }
    
    /**
     TASK-4: If a Task's taskType is `Specific`, then its instances contains at least one TaskInstance.
     TI-3: If a TaskInstance's associated Task's taskType is `Specific`, then the TaskInstance is not associated with a TaskTargetSet.
     */
    static var validateSpecificTask: (Task) throws -> () = { task in
        if try task._taskType == .specific {
            // TASK-4
            XCTAssert(try task._instances.count > 0)
            
            // TI-3
            for instance in try task._instances {
                XCTAssert(instance._targetSet == nil)
            }
        }
    }
    
    /**
     TI-4: TaskInstances with the same associated Task must each have a unique date. (validated by TaskValidator)
     */
    static var validateUniqueTaskInstanceDates: (Task) throws -> () = { task in
        let instanceDates = try (try task._instances).map{ try $0._date }
        let duplicates = Dictionary(grouping: instanceDates, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
    /**
     TTS-9: TaskTargetSets with the same associated Task must have each have a unique priority.
     */
    static var validateUniqueTTSPriorities: (Task) throws -> () = { task in
        let targetSets = try task._targetSets
        let priorities = targetSets.map{ $0._priority }
        let duplicates = Dictionary(grouping: priorities, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
}

