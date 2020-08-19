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
    
    // MARK: - Getting days tests
    
    func testGetDaysOfWeek() {
        let dow: Set<Int16> = Set([1,3,5,7])
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: dow,
                                                    wom: Set([]),
                                                    dom: Set([])))
        XCTAssert(tts.getDaysOfWeek() == dow)
        XCTAssert(tts.getWeeksOfMonth().count == 0)
        XCTAssert(tts.getDaysOfMonth().count == 0)
    }
    
    func testGetWeekdaysOfMonth() {
        let dow: Set<Int16> = Set([1,3,5,7])
        let wom: Set<Int16> = Set([1,3,5])
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: dow,
                                                    wom: wom,
                                                    dom: Set([])))
        XCTAssert(tts.getDaysOfWeek() == dow)
        XCTAssert(tts.getWeeksOfMonth() == wom)
        XCTAssert(tts.getDaysOfMonth().count == 0)
    }
    
    func testGetDaysOfMonth() {
        let dom: Set<Int16> = Set([0,3,6,9,12,15,18,21,24,27,30])
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: dom))
        XCTAssert(tts.getDaysOfWeek().count == 0)
        XCTAssert(tts.getWeeksOfMonth().count == 0)
        XCTAssert(tts.getDaysOfMonth() == dom)
    }
    
    // MARK: - checkDay tests
    
    func testCheckDayDow() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([1,3,5,7]),
                                                    wom: Set([]),
                                                    dom: Set([])))
        XCTAssertFalse(tts.checkDay(day: 3, weekday: 2, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 4, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 5, weekday: 3, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 31, weekday: 5, daysInMonth: 31))
        XCTAssert(tts.checkDay(day: 45, weekday: 7, daysInMonth: 31))
    }
    
    func testCheckDayWom() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([7]),
                                                    wom: Set([1,3,5]),
                                                    dom: Set([])))
        
        XCTAssert(tts.checkDay(day: 2, weekday: 7, daysInMonth: 31))
        XCTAssert(tts.checkDay(day: 7, weekday: 7, daysInMonth: 31))
        
        XCTAssertFalse(tts.checkDay(day: 8, weekday: 7, daysInMonth: 31))
        XCTAssertFalse(tts.checkDay(day: 14, weekday: 7, daysInMonth: 31))
        
        XCTAssert(tts.checkDay(day: 15, weekday: 7, daysInMonth: 31))
        XCTAssert(tts.checkDay(day: 21, weekday: 7, daysInMonth: 31))
        
        XCTAssertFalse(tts.checkDay(day: 22, weekday: 7, daysInMonth: 31))
        XCTAssertFalse(tts.checkDay(day: 23, weekday: 7, daysInMonth: 31))
        
        XCTAssertFalse(tts.checkDay(day: 24, weekday: 7, daysInMonth: 31))
        XCTAssert(tts.checkDay(day: 24, weekday: 7, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 25, weekday: 7, daysInMonth: 31))
        
    }
    
    func testCheckDayDom() {
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 5, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([]),
                                                    wom: Set([]),
                                                    dom: Set([5,10,15])))
        XCTAssertFalse(tts.checkDay(day: 3, weekday: 1, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 1, weekday: 1, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 20, weekday: 1, daysInMonth: 30))
        XCTAssertFalse(tts.checkDay(day: 25, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 5, weekday: 1, daysInMonth: 29))
        XCTAssert(tts.checkDay(day: 10, weekday: 1, daysInMonth: 30))
        XCTAssert(tts.checkDay(day: 15, weekday: 1, daysInMonth: 31))
    }
    
    func testCheckLastDayOfMonth() {
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
