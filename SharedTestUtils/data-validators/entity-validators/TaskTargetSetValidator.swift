//
//  TaskTargetSetValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  TTS-1 (validated by getter)
//  TTS-2 (validated by getter)
//  TTS-8 (defined as non-optional in NSManagedObject subclass)
//  TTS-9 (validated by TaskValidator)
//  TTS-10 (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskTargetSetValidator {
    
    static var validators: [(TaskTargetSet) throws -> ()] = [
        TaskTargetSetValidator.validateOperatorsAndValues,
        TaskTargetSetValidator.validateDayPattern
    ]
    
    static func validateTaskTargetSets(_ taskTargetSets: Set<TaskTargetSet>) {
        for tts in taskTargetSets {
            for validator in TaskTargetSetValidator.validators {
                try! validator(tts)
            }
        }
    }
    
    /**
     TTS-3
     TTS-4
     TTS-5
     TTS-6
     TTS-7
     */
    static var validateOperatorsAndValues: (TaskTargetSet) throws -> () = { tts in
        
        let minOp = try tts._minOperator
        let maxOp = try tts._maxOperator
        
        // TTS-3
        if (maxOp == .na) {
            XCTAssert(tts._max == 0)
        }
        
        // TTS-4
        if (minOp == .na) {
            XCTAssert(tts._min == 0)
        }
        
        // TTS-5
        XCTAssertFalse( minOp == .na && maxOp == .na )
        
        // TTS-6
        if (minOp == .eq ) {
            XCTAssert(maxOp == .na)
        }
        
        // TTS-7
        if (minOp != .na && maxOp != .na ) {
            XCTAssert(tts._min < tts._max)
        }
        
    }
    
}

// MARK: - DayPattern transformable validation

extension TaskTargetSetValidator {
    
    static var validateDayPattern: (TaskTargetSet) throws -> () = { tts in
        DayPatternValidator.validateDayPattern(tts._pattern)
    }
    
}

