//
//  TaskTargetSetTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class TaskTargetSetTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - checkDay tests
    
    func testCheckDay_dow() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([1,3,5,7]),
                                                    wom: Set([]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 5, weekday: 3, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 3, weekday: 2, daysInMonth: 30))
    }
    
    func testCheckDay_wom_rightWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 7, daysInMonth: 31))
    }
    
    func testCheckDay_wom_rightWeekday_rightWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 15, weekday: 7, daysInMonth: 31))
    }
    
    func testCheckDay_wom_wrongWeekday_wrongWeek() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 6, daysInMonth: 31))
    }
    
    func testCheckDay_wom_wrongWeekday_rightWeek() {
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
    func testCheckDay_wom_lastOfMonth() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        XCTAssert(tts.checkDay(day: 24, weekday: 7, daysInMonth: 30))
    }
    
    func testCheckDay_dom() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: Set([5,10,15])))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 15, weekday: 1, daysInMonth: 31))
    }
    
    func testCheckDay_dom_lastDayOfMonth() {
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
