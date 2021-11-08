//
//  TaskInstanceValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TI-1 (defined as non-optional in NSManagedObject subclass)
//  TI-2 (validated by TaskValidator)
//  TI-3 (validated by TaskValidator)
//  TI-4 (validated by TaskValidator)
//  TI-5 (defined as non-optional in NSManagedObject subclass)
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
