//
//  DayPatternValidator.swift
//  SharedTestUtils
//
//  Business rules NOT checked for by this validator:
//  * DP-1 (validated by getter)
//
//  Created by Vincent Young on 7/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class DayPatternValidator {
    
    static var validators: [(DayPattern) throws -> ()] = [
        DayPatternValidator.validateArraysEmptiness
    ]
    
    static func validateDayPattern(_ pattern: DayPattern) {
        for validator in DayPatternValidator.validators {
            try! validator(pattern)
        }
    }
    
    /**
     DP-2
     DP-3
     DP-4
     */
    static var validateArraysEmptiness: (DayPattern) throws-> () = { pattern in
        switch try pattern._type {
        case .dow:
            // DP-2
            XCTAssert(try pattern._daysOfWeek.count > 0)
            XCTAssert(try pattern._weeksOfMonth.count == 0)
            XCTAssert(try pattern._daysOfMonth.count == 0)
        case .wom:
            // DP-3
            XCTAssert(try pattern._daysOfWeek.count > 0)
            XCTAssert(try pattern._weeksOfMonth.count > 0)
            XCTAssert(try pattern._daysOfMonth.count == 0)
        case .dom:
            // DP-4
            XCTAssert(try pattern._daysOfWeek.count == 0)
            XCTAssert(try pattern._weeksOfMonth.count == 0)
            XCTAssert(try pattern._daysOfMonth.count > 0)
        }
    }
    
}
