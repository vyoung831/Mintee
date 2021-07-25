//
//  TaskValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  - TASK-5: A Task's name must be unique. (validated by MOC_Validator)
//
//  Created by Vincent Young on 5/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskValidator {
    
    static var validators: [(Task) -> ()] = [
        TaskValidator.validateTaskType,
        TaskValidator.validateRecurringTask,
        TaskValidator.validateSpecificTask,
        TaskValidator.validateUniqueTaskInstanceDates,
        TaskValidator.validateTaskSummaryAnalysisAssociation,
        validateUniqueTTSPriorities
    ]
    
    static func validateTasks(_ tasks: Set<Task>) {
        for task in tasks {
            for validator in TaskValidator.validators {
                validator(task)
            }
        }
    }
    
    /**
     TASK-1: A Task's taskType can only be one of the following values:
     - `Recurring`
     - `Specific`
     */
    static var validateTaskType: (Task) -> () = { task in
        XCTAssert(task._taskType == 0 || task._taskType == 1)
    }
    
    /**
     TASK-2: If a Task's taskType is `Recurring`, then its startDate and endDate must be non-nil.
     TASK-3: If a Task's taskType is `Recurring`, then its targetSets must contain at least one TaskTargetSet.
     TASK-6: If a Task's taskType is `Recurring`, then its endDate must be later than or equal startDate.
     TI-2: If a TaskInstance's associated Task's taskType is `Recurring`, then the TaskInstance is associated with a TaskTargetSet.
     */
    static var validateRecurringTask: (Task) -> () = { task in
        if task._taskType == 0 {
            // TASK-2 and TASK-6
            XCTAssert(SaveFormatter.storedStringToDate(task._startDate!)!.lessThanOrEqualToDate(SaveFormatter.storedStringToDate(task._endDate!)!))
            
            // TASK-3
            XCTAssert(task._targetSets!.count > 0)
            
            // TI-2
            if let instances = task._instances {
                for instance in instances as! Set<TaskInstance> {
                    XCTAssert(instance._targetSet != nil)
                }
            }
            
        }
    }
    
    /**
     TASK-4: If a Task's taskType is `Specific`, then its instances must contain at least one TaskInstance.
     TASK-8: If a Task's taskType is `Specific`, then its startDate and endDate must be `nil`.
     TASK-9: If a Task's taskType is `Specific`, then its targetSets must be empty.
     TI-3: If a TaskInstance's associated Task's taskType is `Specific`, then the TaskInstance is not associated with a TaskTargetSet.
     */
    static var validateSpecificTask: (Task) -> () = { task in
        
        if task._taskType == 1 {
            
            // TASK-4
            XCTAssert(task._instances!.count > 0)
            
            // TASK-8
            XCTAssert(task._startDate == nil)
            XCTAssert(task._endDate == nil)
            
            // TASK-9
            XCTAssert(task._targetSets!.count == 0)
            
            // TI-3
            if let instances = task._instances {
                for instance in instances as! Set<TaskInstance> {
                    XCTAssert(instance._targetSet == nil)
                }
            }
            
        }
        
    }
    
    /**
     TI-4: TaskInstances with the same associated Task must each have a unique date. (validated by Task_Validator)
     */
    static var validateUniqueTaskInstanceDates: (Task) -> () = { task in
        if let instances = task._instances {
            let taskInstances = instances as! Set<TaskInstance>
            let instanceDates = taskInstances.map{ $0._date }
            let duplicates = Dictionary(grouping: instanceDates, by: {$0}).filter{ $1.count > 1 }.keys
            XCTAssert( duplicates.count == 0)
        }
    }
    
    /**
     TASK-7: A Task must be associated with one and only one TaskSummaryAnalysis.
     */
    static var validateTaskSummaryAnalysisAssociation: (Task) -> () = { task in
        XCTAssert(task._taskSummaryAnalysis != nil)
    }
    
    /**
     TTS-9: TaskTargetSets with the same associated Task must have each have a unique priority.
     */
    static var validateUniqueTTSPriorities: (Task) -> () = { task in
        if let sets = task._targetSets {
            let targetSets = sets as! Set<TaskTargetSet>
            let priorities = targetSets.map{ $0._priority }
            let duplicates = Dictionary(grouping: priorities, by: {$0}).filter{ $1.count > 1 }.keys
            XCTAssert( duplicates.count == 0)
        }
    }
    
}
