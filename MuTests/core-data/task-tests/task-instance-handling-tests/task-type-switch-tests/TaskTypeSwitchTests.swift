//
//  TaskTypeSwitchTests.swift
//  MuTests
//
//  Created by Vincent Young on 8/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest
import CoreData

class TaskTypeSwitchTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }

    func testSpecificToRecurring() throws {
        
        let task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Task",
                        tags: ["Tag"],
                        dates: [])
        XCTAssert(task.taskType == SaveFormatter.taskTypeToStored(type: .specific))
        
        task.updateRecurringInstances(startDate: Date(), endDate: Date(), targetSets: Set<TaskTargetSet>())
        XCTAssert(task.taskType == SaveFormatter.taskTypeToStored(type: .recurring))
        
    }
    
    func testRecurringToSpecific() throws {
        
        let task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Task",
                        tags: ["Tag"],
                        startDate: Date(),
                        endDate: Date(),
                        targetSets: Set<TaskTargetSet>())
        XCTAssert(task.taskType == SaveFormatter.taskTypeToStored(type: .recurring))
        
        task.updateSpecificInstances(dates: [])
        XCTAssert(task.taskType == SaveFormatter.taskTypeToStored(type: .specific))
        
    }

}
