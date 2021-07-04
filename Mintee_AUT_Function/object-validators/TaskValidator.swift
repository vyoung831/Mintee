//
//  TaskValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  - TASK-5: A Task's name must be unique. (constrained by XC data model)
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
        TaskValidator.validateSpecificTask
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
     - Recurring
     - Specific
     */
    static var validateTaskType: (Task) -> () = { task in
        XCTAssert(task._taskType == 0 || task._taskType == 1)
    }
    
    /**
     TASK-2: If a Task's taskType is recurring, startDate and endDate must be non-nil.
     TASK-3: If a Task's taskType is recurring, targetSets must contain at least one TaskTargetSet.
     TASK-6: If a Task's taskType is recurring, endDate must be later than or equal startDate.
     */
    static var validateRecurringTask: (Task) -> () = { task in
        if task._taskType == 0 {
            // TASK-2 and TASK-6
            XCTAssert(SaveFormatter.storedStringToDate(task._startDate!)!.lessThanOrEqualToDate(SaveFormatter.storedStringToDate(task._endDate!)!))

            // TASK-3
            XCTAssert(task._targetSets!.count > 0)
        }
    }
    
    /**
     TASK-4: If a Task's taskType is specific, instances must contain at least one TaskInstance.
     */
    static var validateSpecificTask: (Task) -> () = { task in
        if task._taskType == 1 {
            XCTAssert(task._instances!.count > 0)
        }
    }
    
}
