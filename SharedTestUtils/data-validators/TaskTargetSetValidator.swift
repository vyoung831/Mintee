//
//  TaskTargetSetValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TTS-9: TaskTargetSets with the same associated Task must have each have a unique priority. (validated by Task_Validator)
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
        TaskTargetSetValidator.validateTaskAssociation,
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
     - Less than
     - Less than or equal to
     - Equal to
     - N/A
     TTS-2: A TaskTargetSet's maxOperator can only be one of the following values:
     - Less than
     - Less than or equal to
     - N/A
     TTS-3: If maxOperator is `N/A`, max is 0.
     TTS-4: If minOperator is `N/A`, min is 0.
     TTS-5: A TaskTargetSet's minOperator and maxOperator cannot both be `N/A`.
     TTS-6: If a TaskTargetSet's minOperator is `Equal to`, its maxOperator must be `N/A`.
     TTS-7: If a TaskTargetSet's minOperator and maxOperator are both not `N/A`, min must be less than max.
     */
    static var validateOperatorsAndValues: (TaskTargetSet) -> () = { tts in
        
        XCTAssert( tts._minOperator == 1 || tts._minOperator == 2 || tts._minOperator == 3 || tts._minOperator == 0 ) // TTS-1
        XCTAssert( tts._maxOperator == 1 || tts._maxOperator == 2 || tts._maxOperator == 0 ) // TTS-2
        
        // TTS-3
        if (tts._maxOperator == 0) {
            XCTAssert(tts._max == 0)
        }
        
        // TTS-4
        if (tts._minOperator == 0) {
            XCTAssert(tts._min == 0)
        }
        
        // TTS-5
        XCTAssertFalse( tts._minOperator == 0 && tts._maxOperator == 0 )
        
        // TTS-6
        if (tts._minOperator == 3 ) {
            XCTAssert( tts._maxOperator == 0 )
        }
        
        // TTS-7
        if (tts._minOperator != 0 && tts._maxOperator != 0 ) {
            XCTAssert(tts._min < tts._max)
        }
        
    }
    
    /**
     TTS-8: A TaskTargetSet must be associated with one and only one Task.
     */
    static var validateTaskAssociation: (TaskTargetSet) -> () = { tts in
        XCTAssert( tts._task != nil )
    }
    
}

// MARK: - DayPattern transformable validation

extension TaskTargetSetValidator {
    
    static var validateDayPattern: (TaskTargetSet) -> () = { tts in
        DayPatternValidator.validateDayPattern(tts._pattern!)
    }
    
}

