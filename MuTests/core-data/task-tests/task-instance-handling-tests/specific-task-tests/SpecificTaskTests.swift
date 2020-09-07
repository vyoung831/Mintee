//
//  SpecificTaskTests.swift
//  MuTests
//
//  Created by Vincent Young on 8/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest
import CoreData

class SpecificTaskTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - TaskInstance generation
    
    func testNewTaskInstances() throws {
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        
        let dates: [Date] = [Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!,
                             Calendar.current.date(from: DateComponents(year: 2021, month: 2, day: 1))!,
                             Calendar.current.date(from: DateComponents(year: 2022, month: 3, day: 1))!]
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Task",
                        tags: ["Tag"],
                        dates: dates)
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 3)
        for instance in instances {
            XCTAssert(dates.contains(SaveFormatter.storedStringToDate(instance.date!)))
        }
        
    }
    
    func testUpdateInstances() throws {
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        
        let oldDates: [Date] = [Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!,
                                Calendar.current.date(from: DateComponents(year: 2021, month: 2, day: 1))!,
                                Calendar.current.date(from: DateComponents(year: 2022, month: 3, day: 1))!]
        let task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Task",
                        tags: ["Tag"],
                        dates: oldDates)
        
        let newDates: [Date] = [Calendar.current.date(from: DateComponents(year: 2020, month: 2, day: 1))!,
                                Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!,
                                Calendar.current.date(from: DateComponents(year: 2022, month: 4, day: 1))!]
        task.updateSpecificInstances(dates: newDates)
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 3)
        for instance in instances {
            XCTAssert(newDates.contains(SaveFormatter.storedStringToDate(instance.date!)))
        }
        
    }
    
}
