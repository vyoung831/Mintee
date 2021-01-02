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
    
    func test_checkDay_dow() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([1,3,5,7]),
                                                    wom: Set([]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 5, weekday: 3, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 3, weekday: 2, daysInMonth: 30))
    }
    
    func test_checkDay_wom_rightWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_rightWeekday_rightWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 15, weekday: 7, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 6, daysInMonth: 31))
    }
    
    func test_checkDay_wom_wrongWeekday_rightWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
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
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 24, weekday: 7, daysInMonth: 30))
    }
    
    func test_checkDay_dom() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: Set([5,10,15])))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 15, weekday: 1, daysInMonth: 31))
    }
    
    func test_checkDay_dom_lastDayOfMonth() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: .lt, maxOperator: .lt, priority: 0,
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
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lt_storeValue, lt_storeValue, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lt_storeValue, lte_storeValue, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lt_storeValue, na_storeValue, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lte_storeValue, lt_storeValue, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lte_storeValue, lte_storeValue, 3, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lte_storeValue, na_storeValue, 3, 0))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minLessThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 3, 3))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lt_storeValue, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lte_storeValue, 0, 4))
    }
    
    func test_checkOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 3, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
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
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lt_storeValue, na_storeValue, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lte_storeValue, na_storeValue, 4, 0))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lt_storeValue, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lte_storeValue, 0, 4))
    }
    
    func test_checkOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 4, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
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
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lt, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lt_storeValue, na_storeValue, 5, 0))
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
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .lte, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (lte_storeValue, na_storeValue, 5, 0))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .eq, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 5, 5))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lt, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lt_storeValue, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .lte, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (na_storeValue, lte_storeValue, 0, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .eq, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage == nil)
        XCTAssert(validateResults.operators! == (eq_storeValue, eq_storeValue, 4, 4))
    }
    
    func test_checkOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorNotApplicable() throws {
        let validateResults = TaskTargetSet.validateOperators(minOp: .na, maxOp: .na, min: 5, max: 4)
        XCTAssert(validateResults.errorMessage!.count > 0)
        XCTAssert(validateResults.operators == nil)
    }
    
}
