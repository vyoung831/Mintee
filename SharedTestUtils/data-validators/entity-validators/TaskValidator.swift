//
//  TaskValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  * TASK-1 (validated by getters)
//  * TASK-5 (validated by MOC_Validator)
//  * TASK-7 (defined as non-optional in NSManagedObject subclass)
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
     TASK-3
     TASK-6
     TI-2
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
     TASK-4
     TI-3
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
     TI-4
     */
    static var validateUniqueTaskInstanceDates: (Task) throws -> () = { task in
        let instanceDates = try (try task._instances).map{ try $0._date }
        let duplicates = Dictionary(grouping: instanceDates, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
    /**
     TTS-9
     */
    static var validateUniqueTTSPriorities: (Task) throws -> () = { task in
        let targetSets = try task._targetSets
        let priorities = targetSets.map{ $0._priority }
        let duplicates = Dictionary(grouping: priorities, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
}

