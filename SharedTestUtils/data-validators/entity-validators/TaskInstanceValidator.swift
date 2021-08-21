//
//  TaskInstanceValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TI-1: A TaskInstance is associated with one and only one Task. (defined as non-optional in NSManagedObject subclass)
//  TI-2: If a TaskInstance's associated Task's taskType is `Recurring`, then the TaskInstance is associated with one and only one TaskTargetSet. (validated by TaskValidator)
//  TI-3: If a TaskInstance's associated Task's taskType is `Specific`, then the TaskInstance is not associated with a TaskTargetSet. (validated by TaskValidator)
//  TI-4: TaskInstances with the same associated Task each have a unique date. (validated by TaskValidator)
//  TI-5: A TaskInstance's date is non-nil. (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskInstanceValidator {
    
    static var validators: [(TaskInstance) -> ()] = []
    
    static func validateInstances(_ instances: Set<TaskInstance>) {
        for instance in instances {
            for validator in TaskInstanceValidator.validators {
                validator(instance)
            }
        }
    }
    
}
