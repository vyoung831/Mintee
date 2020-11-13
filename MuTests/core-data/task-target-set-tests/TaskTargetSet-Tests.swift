//
//  TaskTargetSet-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 6/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class TaskTargetSet_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - checkDay tests
    
    func test_checkDay_dow() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([1,3,5,7]),
                                                    wom: Set([]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 5, weekday: 3, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 3, weekday: 2, daysInMonth: 30))
    }
    
    func test_checkDay_wom_rightWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_rightWeekday_rightWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 15, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 6, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_rightWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 6, daysInMonth: 31))
    }
    
    /**
     Test that even though the weekday is the 4th of the month, checkDay returns true because 5 (last of month) was in WOM
     */
    func test_checkDay_wom_lastOfMonth() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 24, weekday: 7, daysInMonth: 30))
    }
    
    func test_checkDay_dom() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: Set([5,10,15])))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 15, weekday: 1, daysInMonth: 31))
    }
    
    func test_checkDay_dom_lastDayOfMonth() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: Set([0])))
        XCTAssertFalse(tts.checkDay(day: 28, weekday: 1, daysInMonth: 29))
        XCTAssertFalse(tts.checkDay(day: 29, weekday: 1, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 29, weekday: 1, daysInMonth: 31))
        XCTAssertFalse(tts.checkDay(day: 30, weekday: 1, daysInMonth: 31))
        XCTAssert(tts.checkDay(day: 29, weekday: 1, daysInMonth: 29))
        XCTAssert(tts.checkDay(day: 30, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 31, weekday: 1, daysInMonth: 31))
    }
    
}

// MARK: - validateOperators tests where min < max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .lt, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .lte, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .lt, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .lte, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}

// MARK: - validateOperators tests where min = max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}

// MARK: - validateOperators tests where min > max

extension TaskTargetSet_Tests {
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lt, maxOperator: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lt, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .lte, maxOperator: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.lte, .na, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .eq, maxOperator: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lt, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.na, .lte, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (.eq, .eq, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOperator: .na, maxOperator: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}

