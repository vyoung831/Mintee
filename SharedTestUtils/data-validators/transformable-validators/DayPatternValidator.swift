//
//  DayPatternValidator.swift
//  SharedTestUtils
//
//  Business rules NOT checked for by this validator:
//  DP-1: A DayPattern's type can only be one of the following values:
//  - Days of week
//  - Weekdays of month
//  - Days of month
//  (constrained by DayPattern's encoding/decoding functions and usage of enum)
//
//  Created by Vincent Young on 7/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class DayPatternValidator {
    
    static var validators: [(DayPattern) -> ()] = [
        DayPatternValidator.validateArraysEmptiness,
    ]
    
    static func validateDayPattern(_ pattern: DayPattern) {
        for validator in DayPatternValidator.validators {
            validator(pattern)
        }
    }
    
    /**
     DP-2: If a DayPattern's type is `Days of week`, then the following are true:
     - daysOfWeek is non-empty
     - weekdaysOfMonth is empty
     - daysOfMonth is empty
     DP-3: If a DayPattern's type is `Weekdays of month`, then the following are true:
     - daysOfWeek is non-empty
     - weekdaysOfMonth is non-empty
     - daysOfMonth is empty
     DP-4: If a DayPattern's type is `Days of month`, then the following are true:
     - daysOfWeek is empty
     - weekdaysOfMonth is empty
     - daysOfMonth is non-empty
     */
    static var validateArraysEmptiness: (DayPattern) -> () = { pattern in
        switch pattern.type {
        case .dow:
            // DP-2
            XCTAssert(pattern.daysOfWeek.count > 0)
            XCTAssert(pattern.weeksOfMonth.count == 0)
            XCTAssert(pattern.daysOfMonth.count == 0)
        case .wom:
            // DP-3
            XCTAssert(pattern.daysOfWeek.count > 0)
            XCTAssert(pattern.weeksOfMonth.count > 0)
            XCTAssert(pattern.daysOfMonth.count == 0)
        case .dom:
            // DP-4
            XCTAssert(pattern.daysOfWeek.count == 0)
            XCTAssert(pattern.weeksOfMonth.count == 0)
            XCTAssert(pattern.daysOfMonth.count > 0)
        }
    }
    
}
