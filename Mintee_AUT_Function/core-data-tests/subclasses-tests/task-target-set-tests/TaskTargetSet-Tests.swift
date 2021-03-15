//
//  TaskTargetSet-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 6/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
@testable import SharedTestUtils
import XCTest
import CoreData

class TaskTargetSet_Tests: XCTestCase {
    
    let lt_storeValue: Int16 = SaveFormatter.equalityOperatorToStored(.lt)
    let lte_storeValue: Int16 = SaveFormatter.equalityOperatorToStored(.lte)
    let eq_storeValue: Int16 = SaveFormatter.equalityOperatorToStored(.eq)
    let na_storeValue: Int16 = SaveFormatter.equalityOperatorToStored(.na)
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - checkDay tests
    
    func test_checkDay_dow() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.sunday, .tuesday, .thursday, .saturday]),
                                                        wom: Set([]),
                                                        dom: Set([])))
        XCTAssert(try tts.checkDay(day: 5, weekday: 3, daysInMonth: 30))
        XCTAssertFalse(try tts.checkDay(day: 3, weekday: 2, daysInMonth: 30))
    }
    
    func test_checkDay_wom_rightWeekday_wrongWeek() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.saturday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                                        dom: Set([])))
        XCTAssertFalse(try tts.checkDay(day: 8, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_rightWeekday_rightWeek() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.saturday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                                        dom: Set([])))
        XCTAssert(try tts.checkDay(day: 15, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_wrongWeek() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.saturday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                                        dom: Set([])))
        XCTAssertFalse(try tts.checkDay(day: 8, weekday: 6, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_rightWeek() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.saturday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                                        dom: Set([])))
        XCTAssertFalse(try tts.checkDay(day: 1, weekday: 6, daysInMonth: 31))
    }
    
    /**
     Test that even though the weekday is the 4th of the month, checkDay returns true because 5 (last of month) was in WOM
     */
    func test_checkDay_wom_lastOfMonth() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.saturday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                                        dom: Set([])))
        XCTAssert(try tts.checkDay(day: 24, weekday: 7, daysInMonth: 30))
    }
    
    func test_checkDay_dom() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set([]),
                                                        wom: Set([]),
                                                        dom: Set<SaveFormatter.dayOfMonth>([.five, .ten, .fifteen])))
        XCTAssertFalse(try tts.checkDay(day: 1, weekday: 1, daysInMonth: 30))
        XCTAssert(try tts.checkDay(day: 15, weekday: 1, daysInMonth: 31))
    }
    
    func test_checkDay_dom_lastDayOfMonth() throws {
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set([]),
                                                        wom: Set([]),
                                                        dom: Set<SaveFormatter.dayOfMonth>([.last])))
        XCTAssertFalse(try tts.checkDay(day: 28, weekday: 1, daysInMonth: 29))
        XCTAssertFalse(try tts.checkDay(day: 29, weekday: 1, daysInMonth: 30))
        XCTAssertFalse(try tts.checkDay(day: 29, weekday: 1, daysInMonth: 31))
        XCTAssertFalse(try tts.checkDay(day: 30, weekday: 1, daysInMonth: 31))
        XCTAssert(try tts.checkDay(day: 29, weekday: 1, daysInMonth: 29))
        XCTAssert(try tts.checkDay(day: 30, weekday: 1, daysInMonth: 30))
        XCTAssert(try tts.checkDay(day: 31, weekday: 1, daysInMonth: 31))
    }
    
}

// MARK: - validateOperators tests where min < max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .lt, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .lte, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .lt, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .lte, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}

// MARK: - validateOperators tests where min = max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}

// MARK: - validateOperators tests where min > max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .na, 4, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}
