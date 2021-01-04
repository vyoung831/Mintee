//
//  Task-InstanceDelta-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 9/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
@testable import SharedTestUtils
import CoreData
import XCTest

class Task_InstanceDelta_Tests: XCTestCase {
    
    let dowMin: Float = 1, dowMax: Float = 2, womMin: Float = 3, womMax: Float = 4, domMin: Float = 5, domMax: Float = 6
    
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<Int16>([1,2,3,6]), wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: dowMin, max: dowMax,
                             minOperator: .lt, maxOperator: .lt,
                             priority: 3,
                             pattern: dowPattern)
    }
    func getWomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<Int16>([2,4]), wom: Set<Int16>([1,3,5]), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: womMin, max: womMax,
                             minOperator: .lt, maxOperator: .lt,
                             priority: 6,
                             pattern: womPattern)
    }
    func getDomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([0,1,2,3,4,5,6,7,8,9,10]))
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: domMin, max: domMax,
                             minOperator: .lt, maxOperator: .lt,
                             priority: 9,
                             pattern: domPattern)
    }
    
    /*
     Dates from Jan 1, 2020 to Jan 1, 2021 and String representations of dates that each TaskTargetSet applies to
     */
    var task: Task!
    let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
    let globalDowDates: Set<String> =  Set(["2019-11-01", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-08", "2019-11-10", "2019-11-11", "2019-11-12", "2019-11-15", "2019-11-17", "2019-11-18", "2019-11-19", "2019-11-22", "2019-11-24", "2019-11-25", "2019-11-26", "2019-11-29", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-06", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-13", "2019-12-15", "2019-12-16", "2019-12-17", "2019-12-20", "2019-12-22", "2019-12-23", "2019-12-24", "2019-12-27", "2019-12-29", "2019-12-30", "2019-12-31", "2020-01-03", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-10", "2020-01-12", "2020-01-13", "2020-01-14", "2020-01-17", "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-24", "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-31", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-07", "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-14", "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-21", "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-28", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-06", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-13", "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-20", "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-27", "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-03", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-10", "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-17", "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-24", "2020-04-26", "2020-04-27", "2020-04-28", "2020-05-01", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-08", "2020-05-10", "2020-05-11", "2020-05-12", "2020-05-15", "2020-05-17", "2020-05-18", "2020-05-19", "2020-05-22", "2020-05-24", "2020-05-25", "2020-05-26", "2020-05-29", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-05", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-12", "2020-06-14", "2020-06-15", "2020-06-16", "2020-06-19", "2020-06-21", "2020-06-22", "2020-06-23", "2020-06-26", "2020-06-28", "2020-06-29", "2020-06-30", "2020-07-03", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-10", "2020-07-12", "2020-07-13", "2020-07-14", "2020-07-17", "2020-07-19", "2020-07-20", "2020-07-21", "2020-07-24", "2020-07-26", "2020-07-27", "2020-07-28", "2020-07-31", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-07", "2020-08-09", "2020-08-10", "2020-08-11", "2020-08-14", "2020-08-16", "2020-08-17", "2020-08-18", "2020-08-21", "2020-08-23", "2020-08-24", "2020-08-25", "2020-08-28", "2020-08-30", "2020-08-31", "2020-09-01", "2020-09-04", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-11", "2020-09-13", "2020-09-14", "2020-09-15", "2020-09-18", "2020-09-20", "2020-09-21", "2020-09-22", "2020-09-25", "2020-09-27", "2020-09-28", "2020-09-29", "2020-10-02", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-09", "2020-10-11", "2020-10-12", "2020-10-13", "2020-10-16", "2020-10-18", "2020-10-19", "2020-10-20", "2020-10-23", "2020-10-25", "2020-10-26", "2020-10-27", "2020-10-30", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-06", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-13", "2020-11-15", "2020-11-16", "2020-11-17", "2020-11-20", "2020-11-22", "2020-11-23", "2020-11-24", "2020-11-27", "2020-11-29", "2020-11-30", "2020-12-01", "2020-12-04", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-11", "2020-12-13", "2020-12-14", "2020-12-15", "2020-12-18", "2020-12-20", "2020-12-21", "2020-12-22", "2020-12-25", "2020-12-27", "2020-12-28", "2020-12-29", "2021-01-01", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-08", "2021-01-10", "2021-01-11", "2021-01-12", "2021-01-15", "2021-01-17", "2021-01-18", "2021-01-19", "2021-01-22", "2021-01-24", "2021-01-25", "2021-01-26", "2021-01-29", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-05", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-12", "2021-02-14", "2021-02-15", "2021-02-16", "2021-02-19", "2021-02-21", "2021-02-22", "2021-02-23", "2021-02-26", "2021-02-28", "2021-03-01"])
    let globalWomDates: Set<String> = Set(["2019-11-04", "2019-11-06", "2019-11-18", "2019-11-20", "2019-11-25", "2019-11-27", "2019-12-02", "2019-12-04", "2019-12-16", "2019-12-18", "2019-12-25", "2019-12-30", "2020-01-01", "2020-01-06", "2020-01-15", "2020-01-20", "2020-01-27", "2020-01-29", "2020-02-03", "2020-02-05", "2020-02-17", "2020-02-19", "2020-02-24", "2020-02-26", "2020-03-02", "2020-03-04", "2020-03-16", "2020-03-18", "2020-03-25", "2020-03-30", "2020-04-01", "2020-04-06", "2020-04-15", "2020-04-20", "2020-04-27", "2020-04-29", "2020-05-04", "2020-05-06", "2020-05-18", "2020-05-20", "2020-05-25", "2020-05-27", "2020-06-01", "2020-06-03", "2020-06-15", "2020-06-17", "2020-06-24", "2020-06-29", "2020-07-01", "2020-07-06", "2020-07-15", "2020-07-20", "2020-07-27", "2020-07-29", "2020-08-03", "2020-08-05", "2020-08-17", "2020-08-19", "2020-08-26", "2020-08-31", "2020-09-02", "2020-09-07", "2020-09-16", "2020-09-21", "2020-09-28", "2020-09-30", "2020-10-05", "2020-10-07", "2020-10-19", "2020-10-21", "2020-10-26", "2020-10-28", "2020-11-02", "2020-11-04", "2020-11-16", "2020-11-18", "2020-11-25", "2020-11-30", "2020-12-02", "2020-12-07", "2020-12-16", "2020-12-21", "2020-12-28", "2020-12-30", "2021-01-04", "2021-01-06", "2021-01-18", "2021-01-20", "2021-01-25", "2021-01-27", "2021-02-01", "2021-02-03", "2021-02-15", "2021-02-17", "2021-02-22", "2021-02-24", "2021-03-01"])
    let globalDomDates: Set<String> = Set(["2019-11-01", "2019-11-02", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-06", "2019-11-07", "2019-11-08", "2019-11-09", "2019-11-10", "2019-11-30", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-04", "2019-12-05", "2019-12-06", "2019-12-07", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-31", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-08", "2020-01-09", "2020-01-10", "2020-01-31", "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10", "2020-02-29", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-31", "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10", "2020-04-30", "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09", "2020-05-10", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-03", "2020-06-04", "2020-06-05", "2020-06-06", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-10", "2020-06-30", "2020-07-01", "2020-07-02", "2020-07-03", "2020-07-04", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-08", "2020-07-09", "2020-07-10", "2020-07-31", "2020-08-01", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-05", "2020-08-06", "2020-08-07", "2020-08-08", "2020-08-09", "2020-08-10", "2020-08-31", "2020-09-01", "2020-09-02", "2020-09-03", "2020-09-04", "2020-09-05", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-09", "2020-09-10", "2020-09-30", "2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-07", "2020-10-08", "2020-10-09", "2020-10-10", "2020-10-31", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06", "2020-11-07", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-30", "2020-12-01", "2020-12-02", "2020-12-03", "2020-12-04", "2020-12-05", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-09", "2020-12-10", "2020-12-31", "2021-01-01", "2021-01-02", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-06", "2021-01-07", "2021-01-08", "2021-01-09", "2021-01-10", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-03", "2021-02-04", "2021-02-05", "2021-02-06", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-10", "2021-02-28", "2021-03-01"])
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
        task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                    insertInto: CDCoordinator.moc,
                    name: "Task",
                    tags: [],
                    startDate: startDate,
                    endDate: endDate,
                    targetSets: Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc),
                                    getWomTargetSet(CDCoordinator.moc),
                                    getDomTargetSet(CDCoordinator.moc)))
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
}

// MARK: - getDeltaInstancesSpecific tests

extension Task_InstanceDelta_Tests {
    
    
    
}

// MARK: - getDeltaInstancesRecurring tests

extension Task_InstanceDelta_Tests {
    
    // MARK: - Start or end date changes tests
    
    func test_getDeltaInstancesRecurring_startDateEarlier() throws {
        
        let newStart = Calendar.current.date(from: DateComponents(year: 2019, month: 1, day: 1))!
        let targetSets = Set((task._targetSets as! Set<TaskTargetSet>))
        let delta = Set(task.getDeltaInstancesRecurring(startDate: newStart, endDate: endDate, dayPatterns: Set(targetSets.map{$0._pattern!}) ))
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_startDateLater() throws {
        
        let newDowDates: Set<String> = Set(["2020-07-03", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-10", "2020-07-12", "2020-07-13", "2020-07-14", "2020-07-17", "2020-07-19", "2020-07-20", "2020-07-21", "2020-07-24", "2020-07-26", "2020-07-27", "2020-07-28", "2020-07-31", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-07", "2020-08-09", "2020-08-10", "2020-08-11", "2020-08-14", "2020-08-16", "2020-08-17", "2020-08-18", "2020-08-21", "2020-08-23", "2020-08-24", "2020-08-25", "2020-08-28", "2020-08-30", "2020-08-31", "2020-09-01", "2020-09-04", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-11", "2020-09-13", "2020-09-14", "2020-09-15", "2020-09-18", "2020-09-20", "2020-09-21", "2020-09-22", "2020-09-25", "2020-09-27", "2020-09-28", "2020-09-29", "2020-10-02", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-09", "2020-10-11", "2020-10-12", "2020-10-13", "2020-10-16", "2020-10-18", "2020-10-19", "2020-10-20", "2020-10-23", "2020-10-25", "2020-10-26", "2020-10-27", "2020-10-30", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-06", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-13", "2020-11-15", "2020-11-16", "2020-11-17", "2020-11-20", "2020-11-22", "2020-11-23", "2020-11-24", "2020-11-27", "2020-11-29", "2020-11-30", "2020-12-01", "2020-12-04", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-11", "2020-12-13", "2020-12-14", "2020-12-15", "2020-12-18", "2020-12-20", "2020-12-21", "2020-12-22", "2020-12-25", "2020-12-27", "2020-12-28", "2020-12-29", "2021-01-01", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-08", "2021-01-10", "2021-01-11", "2021-01-12", "2021-01-15", "2021-01-17", "2021-01-18", "2021-01-19", "2021-01-22", "2021-01-24", "2021-01-25", "2021-01-26", "2021-01-29", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-05", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-12", "2021-02-14", "2021-02-15", "2021-02-16", "2021-02-19", "2021-02-21", "2021-02-22", "2021-02-23", "2021-02-26", "2021-02-28", "2021-03-01"]
        )
        let newWomDates: Set<String> = Set(["2020-07-01", "2020-07-06", "2020-07-15", "2020-07-20", "2020-07-27", "2020-07-29", "2020-08-03", "2020-08-05", "2020-08-17", "2020-08-19", "2020-08-26", "2020-08-31", "2020-09-02", "2020-09-07", "2020-09-16", "2020-09-21", "2020-09-28", "2020-09-30", "2020-10-05", "2020-10-07", "2020-10-19", "2020-10-21", "2020-10-26", "2020-10-28", "2020-11-02", "2020-11-04", "2020-11-16", "2020-11-18", "2020-11-25", "2020-11-30", "2020-12-02", "2020-12-07", "2020-12-16", "2020-12-21", "2020-12-28", "2020-12-30", "2021-01-04", "2021-01-06", "2021-01-18", "2021-01-20", "2021-01-25", "2021-01-27", "2021-02-01", "2021-02-03", "2021-02-15", "2021-02-17", "2021-02-22", "2021-02-24", "2021-03-01"]
        ).subtracting(newDowDates)
        let newDomDates: Set<String> = Set(["2020-07-01", "2020-07-02", "2020-07-03", "2020-07-04", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-08", "2020-07-09", "2020-07-10", "2020-07-31", "2020-08-01", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-05", "2020-08-06", "2020-08-07", "2020-08-08", "2020-08-09", "2020-08-10", "2020-08-31", "2020-09-01", "2020-09-02", "2020-09-03", "2020-09-04", "2020-09-05", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-09", "2020-09-10", "2020-09-30", "2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-07", "2020-10-08", "2020-10-09", "2020-10-10", "2020-10-31", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06", "2020-11-07", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-30", "2020-12-01", "2020-12-02", "2020-12-03", "2020-12-04", "2020-12-05", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-09", "2020-12-10", "2020-12-31", "2021-01-01", "2021-01-02", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-06", "2021-01-07", "2021-01-08", "2021-01-09", "2021-01-10", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-03", "2021-02-04", "2021-02-05", "2021-02-06", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-10", "2021-02-28", "2021-03-01"]
        ).subtracting(newWomDates).subtracting(newDowDates)
        let newStart = Calendar.current.date(from: DateComponents(year: 2020, month: 7, day: 1))!
        
        let targetSets = Set((task._targetSets as! Set<TaskTargetSet>))
        var delta = Set(task.getDeltaInstancesRecurring(startDate: newStart, endDate: endDate, dayPatterns: Set(targetSets.map{$0._pattern!})).map{Date.toYMDTest($0)} )
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates)).subtracting(newDowDates).subtracting(newWomDates).subtracting(newDomDates)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_endDateEarlier() throws {
        
        let newDowDates: Set<String> = Set(["2019-11-01", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-08", "2019-11-10", "2019-11-11", "2019-11-12", "2019-11-15", "2019-11-17", "2019-11-18", "2019-11-19", "2019-11-22", "2019-11-24", "2019-11-25", "2019-11-26", "2019-11-29", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-06", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-13", "2019-12-15", "2019-12-16", "2019-12-17", "2019-12-20", "2019-12-22", "2019-12-23", "2019-12-24", "2019-12-27", "2019-12-29", "2019-12-30", "2019-12-31", "2020-01-03", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-10", "2020-01-12", "2020-01-13", "2020-01-14", "2020-01-17", "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-24", "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-31", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-07", "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-14", "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-21", "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-28", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-06", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-13", "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-20", "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-27", "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-03", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-10", "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-17", "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-24", "2020-04-26", "2020-04-27", "2020-04-28", "2020-05-01", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-08", "2020-05-10", "2020-05-11", "2020-05-12", "2020-05-15", "2020-05-17", "2020-05-18", "2020-05-19", "2020-05-22", "2020-05-24", "2020-05-25", "2020-05-26", "2020-05-29", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-05", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-12", "2020-06-14", "2020-06-15", "2020-06-16", "2020-06-19", "2020-06-21", "2020-06-22", "2020-06-23", "2020-06-26", "2020-06-28", "2020-06-29", "2020-06-30"])
        let newWomDates: Set<String> = Set(["2019-11-04", "2019-11-06", "2019-11-18", "2019-11-20", "2019-11-25", "2019-11-27", "2019-12-02", "2019-12-04", "2019-12-16", "2019-12-18", "2019-12-25", "2019-12-30", "2020-01-01", "2020-01-06", "2020-01-15", "2020-01-20", "2020-01-27", "2020-01-29", "2020-02-03", "2020-02-05", "2020-02-17", "2020-02-19", "2020-02-24", "2020-02-26", "2020-03-02", "2020-03-04", "2020-03-16", "2020-03-18", "2020-03-25", "2020-03-30", "2020-04-01", "2020-04-06", "2020-04-15", "2020-04-20", "2020-04-27", "2020-04-29", "2020-05-04", "2020-05-06", "2020-05-18", "2020-05-20", "2020-05-25", "2020-05-27", "2020-06-01", "2020-06-03", "2020-06-15", "2020-06-17", "2020-06-24", "2020-06-29"]).subtracting(newDowDates)
        let newDomDates: Set<String> = Set(["2019-11-01", "2019-11-02", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-06", "2019-11-07", "2019-11-08", "2019-11-09", "2019-11-10", "2019-11-30", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-04", "2019-12-05", "2019-12-06", "2019-12-07", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-31", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-08", "2020-01-09", "2020-01-10", "2020-01-31", "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10", "2020-02-29", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-31", "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10", "2020-04-30", "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09", "2020-05-10", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-03", "2020-06-04", "2020-06-05", "2020-06-06", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-10", "2020-06-30"]).subtracting(newWomDates).subtracting(newDowDates)
        let newEnd = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 30))!
        
        let targetSets = Set((task._targetSets as! Set<TaskTargetSet>))
        var delta = Set( task.getDeltaInstancesRecurring(startDate: startDate, endDate: newEnd, dayPatterns: Set(targetSets.map{$0._pattern!})).map{Date.toYMDTest($0)} )
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates)).subtracting(newDowDates).subtracting(newWomDates).subtracting(newDomDates)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_endDateLater() throws {
        
        let newEnd = Calendar.current.date(from: DateComponents(year: 2022, month: 1, day: 1))!
        let targetSets = Set((task._targetSets as! Set<TaskTargetSet>))
        let delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: newEnd, dayPatterns: Set(targetSets.map{$0._pattern!}) ))
        XCTAssert(delta.count == 0)
        
    }
    
    // MARK: - TTS deletion tests
    
    func test_getDeltaInstancesRecurring_deleteDow() throws {
        
        let newWomDates: Set<String> = globalWomDates
        let newDomDates: Set<String> = globalDomDates.subtracting(newWomDates)
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates)).subtracting(newWomDates).subtracting(newDomDates)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_deleteWom() throws {
        
        let newDowDates: Set<String> = globalDowDates
        let newDomDates: Set<String> = globalDomDates.subtracting(newDowDates)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates)).subtracting(newDowDates).subtracting(newDomDates)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_deleteDom() throws {
        
        let newDowDates: Set<String> = globalDowDates
        let newWomDates: Set<String> = globalWomDates.subtracting(newDowDates)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates)).subtracting(newDowDates).subtracting(newWomDates)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    func test_getDeltaInstancesRecurring_deleteAllTargetSets() throws {
        
        let newTargetSets: Set<TaskTargetSet> = []
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDowDates.union(globalWomDates).union(globalDomDates))
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
    // MARK: - TTS addition tests
    
    /**
     Add a new .dow TaskTargetSet at highest priority
     New TaskTargetSets by priority = [newDow, oldDow, oldWom, oldDom]
     */
    func test_getDeltaInstancesRecurring_addTTS() throws {
        
        let newDowDatesMin = dowMin + 100; let newDowDatesMax = dowMax + 100
        let newDowDatesSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                           insertInto: CDCoordinator.moc,
                                           min: newDowDatesMin, max: newDowDatesMax, minOperator: .lt, maxOperator: .lt, priority: 0,
                                           pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc), newDowDatesSet)
        
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
    }
    
    // MARK: - TTS addition and deletion tests
    
    /**
     Delete the existing .dow TaskTargetSets and add new .wom, .dow, and .dom TaskTargetSets
     New TaskTargetSets by priority = [newWom, newDow, oldWom, newDom, oldDom]
     */
    func test_getDeltaInstancesRecurring_addWomDowDom_deleteDow() throws {
        
        let newDowDatesMin = dowMin + 100; let newDowDatesMax = dowMax + 100; let newWomDatesMin = womMin + 100; let newWomDatesMax = womMax + 100; let newDomDatesMin = domMin + 100; let newDomDatesMax = domMax + 100
        let newDowDatesSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                           insertInto: CDCoordinator.moc,
                                           min: newDowDatesMin, max: newDowDatesMax, minOperator: .lt, maxOperator: .lt, priority: 1,
                                           pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        let newWomDatesSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                           insertInto: CDCoordinator.moc,
                                           min: newWomDatesMin, max: newWomDatesMax, minOperator: .lt, maxOperator: .lt, priority: 0,
                                           pattern: DayPattern(dow: Set([2,6]), wom: Set([1,3,5]), dom: Set()))
        let newDomDatesSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                           insertInto: CDCoordinator.moc,
                                           min: newDomDatesMin, max: newDomDatesMax, minOperator: .lt, maxOperator: .lt, priority: 7,
                                           pattern: DayPattern(dow: Set(), wom: Set(), dom: Set([3,6,9,12,15,18,21,24,27,30])))
        
        let newWomDates: Set<String> = Set(["2019-11-04", "2019-11-11", "2019-11-18", "2019-11-25", "2019-12-02", "2019-12-09", "2019-12-16", "2019-12-23", "2019-12-30", "2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28", "2021-01-04", "2021-01-11", "2021-01-18", "2021-01-25", "2021-02-01", "2021-02-08", "2021-02-15", "2021-02-22", "2021-03-01"]
        )
        let newDowDates: Set<String> = Set(["2019-11-01", "2019-11-04", "2019-11-15", "2019-11-18", "2019-11-25", "2019-11-29", "2019-12-02", "2019-12-06", "2019-12-16", "2019-12-20", "2019-12-27", "2019-12-30", "2020-01-03", "2020-01-06", "2020-01-17", "2020-01-20", "2020-01-27", "2020-01-31", "2020-02-03", "2020-02-07", "2020-02-17", "2020-02-21", "2020-02-24", "2020-02-28", "2020-03-02", "2020-03-06", "2020-03-16", "2020-03-20", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-17", "2020-04-20", "2020-04-24", "2020-04-27", "2020-05-01", "2020-05-04", "2020-05-15", "2020-05-18", "2020-05-25", "2020-05-29", "2020-06-01", "2020-06-05", "2020-06-15", "2020-06-19", "2020-06-26", "2020-06-29", "2020-07-03", "2020-07-06", "2020-07-17", "2020-07-20", "2020-07-27", "2020-07-31", "2020-08-03", "2020-08-07", "2020-08-17", "2020-08-21", "2020-08-28", "2020-08-31", "2020-09-04", "2020-09-07", "2020-09-18", "2020-09-21", "2020-09-25", "2020-09-28", "2020-10-02", "2020-10-05", "2020-10-16", "2020-10-19", "2020-10-26", "2020-10-30", "2020-11-02", "2020-11-06", "2020-11-16", "2020-11-20", "2020-11-27", "2020-11-30", "2020-12-04", "2020-12-07", "2020-12-18", "2020-12-21", "2020-12-25", "2020-12-28", "2021-01-01", "2021-01-04", "2021-01-15", "2021-01-18", "2021-01-25", "2021-01-29", "2021-02-01", "2021-02-05", "2021-02-15", "2021-02-19", "2021-02-22", "2021-02-26", "2021-03-01"]
        ).subtracting(newWomDates)
        let oldWomDates: Set<String> = globalWomDates.subtracting(newDowDates).subtracting(newWomDates)
        let newDomDates: Set<String> = Set(["2019-11-03", "2019-11-06", "2019-11-09", "2019-11-12", "2019-11-15", "2019-11-18", "2019-11-21", "2019-11-24", "2019-11-27", "2019-11-30", "2019-12-03", "2019-12-06", "2019-12-09", "2019-12-12", "2019-12-15", "2019-12-18", "2019-12-21", "2019-12-24", "2019-12-27", "2019-12-30", "2020-01-03", "2020-01-06", "2020-01-09", "2020-01-12", "2020-01-15", "2020-01-18", "2020-01-21", "2020-01-24", "2020-01-27", "2020-01-30", "2020-02-03", "2020-02-06", "2020-02-09", "2020-02-12", "2020-02-15", "2020-02-18", "2020-02-21", "2020-02-24", "2020-02-27", "2020-03-03", "2020-03-06", "2020-03-09", "2020-03-12", "2020-03-15", "2020-03-18", "2020-03-21", "2020-03-24", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-09", "2020-04-12", "2020-04-15", "2020-04-18", "2020-04-21", "2020-04-24", "2020-04-27", "2020-04-30", "2020-05-03", "2020-05-06", "2020-05-09", "2020-05-12", "2020-05-15", "2020-05-18", "2020-05-21", "2020-05-24", "2020-05-27", "2020-05-30", "2020-06-03", "2020-06-06", "2020-06-09", "2020-06-12", "2020-06-15", "2020-06-18", "2020-06-21", "2020-06-24", "2020-06-27", "2020-06-30", "2020-07-03", "2020-07-06", "2020-07-09", "2020-07-12", "2020-07-15", "2020-07-18", "2020-07-21", "2020-07-24", "2020-07-27", "2020-07-30", "2020-08-03", "2020-08-06", "2020-08-09", "2020-08-12", "2020-08-15", "2020-08-18", "2020-08-21", "2020-08-24", "2020-08-27", "2020-08-30", "2020-09-03", "2020-09-06", "2020-09-09", "2020-09-12", "2020-09-15", "2020-09-18", "2020-09-21", "2020-09-24", "2020-09-27", "2020-09-30", "2020-10-03", "2020-10-06", "2020-10-09", "2020-10-12", "2020-10-15", "2020-10-18", "2020-10-21", "2020-10-24", "2020-10-27", "2020-10-30", "2020-11-03", "2020-11-06", "2020-11-09", "2020-11-12", "2020-11-15", "2020-11-18", "2020-11-21", "2020-11-24", "2020-11-27", "2020-11-30", "2020-12-03", "2020-12-06", "2020-12-09", "2020-12-12", "2020-12-15", "2020-12-18", "2020-12-21", "2020-12-24", "2020-12-27", "2020-12-30", "2021-01-03", "2021-01-06", "2021-01-09", "2021-01-12", "2021-01-15", "2021-01-18", "2021-01-21", "2021-01-24", "2021-01-27", "2021-01-30", "2021-02-03", "2021-02-06", "2021-02-09", "2021-02-12", "2021-02-15", "2021-02-18", "2021-02-21", "2021-02-24", "2021-02-27"]
        ).subtracting(oldWomDates).subtracting(newDowDates).subtracting(newWomDates)
        let oldDomDates: Set<String> = globalDomDates.subtracting(newDomDates).subtracting(oldWomDates).subtracting(newDowDates).subtracting(newWomDates)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc),newDowDatesSet,newWomDatesSet,newDomDatesSet)
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!})).map{Date.toYMDTest($0)})
        let datesStillExisting = newWomDates.union(newDowDates).union(oldWomDates).union(newDomDates).union(oldDomDates)
        var expectedDelta = globalDowDates.subtracting( datesStillExisting )
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
    }
    
}

// MARK: - getDeltaInstancesRecurring performance tests

extension Task_InstanceDelta_Tests {
    
    // MARK: - TTS deletion tests
    
    func testPerformance_getDeltaInstancesRecurring_performance_fiveYears_deleteOneTTS() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
        }
        
    }
    
    func testPerformance_getDeltaInstancesRecurring_performance_tenYears_deleteOneTTS() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
        }
        
    }
    
    func testPerformance_getDeltaInstancesRecurring_performance_twentyFiveYears_deleteOneTTS() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
        }
        
    }
    
}

