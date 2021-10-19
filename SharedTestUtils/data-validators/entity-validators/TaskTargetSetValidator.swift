//
//  TaskTargetSetValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TTS-8: A TaskTargetSet is associated with one and only one Task. (defined as non-optional in NSManagedObject subclass)
//  TTS-9: TaskTargetSets with the same associated Task each have a unique priority. (validated by TaskValidator)
//  TTS-10: A TaskTargetSet's pattern is non-nil. (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskTargetSetValidator {
    
    static var validators: [(TaskTargetSet) -> ()] = [
        TaskTargetSetValidator.validateOperatorsAndValues,
        TaskTargetSetValidator.validateDayPattern
    ]
    
    static func validateTaskTargetSets(_ taskTargetSets: Set<TaskTargetSet>) {
        for tts in taskTargetSets {
            for validator in TaskTargetSetValidator.validators {
                validator(tts)
            }
        }
    }
    
    /**
     TTS-1: A TaskTargetSet's minOperator can only be one of the following values:
     - `Less than`
     - `Less than or equal to`
     - `Equal to`
     - `N/A`
     TTS-2: A TaskTargetSet's maxOperator can only be one of the following values:
     - `Less than`
     - `Less than or equal to`
     - `N/A`
     TTS-3: If a TaskTargetSet's maxOperator is `N/A`, then its max is `0`.
     TTS-4: If a TaskTargetSet's minOperator is `N/A`, then its min is `0`.
     TTS-5: A TaskTargetSet's minOperator and maxOperator cannot both be `N/A`.
     TTS-6: If a TaskTargetSet's minOperator is `Equal to`, then its maxOperator is `N/A`.
     TTS-7: If a TaskTargetSet's minOperator and maxOperator are both not `N/A`, then its min is less than its max.
     */
    static var validateOperatorsAndValues: (TaskTargetSet) -> () = { tts in
        
        XCTAssert( tts._minOperator == .lt || tts._minOperator == .lte || tts._minOperator == .eq || tts._minOperator == .na ) // TTS-1
        XCTAssert( tts._maxOperator == .lt || tts._maxOperator == .lte || tts._maxOperator == .na ) // TTS-2
        
        // TTS-3
        if (tts._maxOperator == .na) {
            XCTAssert(tts._max == 0)
        }
        
        // TTS-4
        if (tts._minOperator == .na) {
            XCTAssert(tts._min == 0)
        }
        
        // TTS-5
        XCTAssertFalse( tts._minOperator == .na && tts._maxOperator == .na )
        
        // TTS-6
        if (tts._minOperator == .eq ) {
            XCTAssert( tts._maxOperator == .na )
        }
        
        // TTS-7
        if (tts._minOperator != .na && tts._maxOperator != .na ) {
            XCTAssert(tts._min < tts._max)
        }
        
    }
    
}

// MARK: - DayPattern transformable validation

extension TaskTargetSetValidator {
    
    static var validateDayPattern: (TaskTargetSet) -> () = { tts in
        DayPatternValidator.validateDayPattern(tts._pattern)
    }
    
}

