//
//  TaskTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class Task_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - Core Data Restraint tests
    
    /**
     Test that two Tasks with the same name can't be saved to the MOC
     */
    func testTaskNameRestraint() {
        let task1 = Task(context: CDCoordinator.moc); task1.name = "Task"
        let task2 = Task(context: CDCoordinator.moc); task2.name = "Task"
        do { try CDCoordinator.moc.save() } catch {
            return
        }
        XCTFail()
    }
    
    // MARK: - Task deletion tests
    
    /**
     Test that deleteSelf deletes the Task, its Tags, its TaskInstances, and its TaskTargetSets
     */
    func testDeleteTask() throws {
        let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2019, month: 3, day: 1))!
        let tts = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc, min: 0, max: 3, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set([1,2,3,4,5,6,7]), wom: Set([]), dom: Set([])))
        
        let task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Task", tags: ["Tag1","Tag2"],
                        startDate: startDate, endDate: endDate,
                        targetSets: [tts])
        
        task.deleteSelf()
        let tasks = try CDCoordinator.moc.fetch(Task.fetchRequest()) as [Task]
        let tags = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        let targetSets = try CDCoordinator.moc.fetch(TaskTargetSet.fetchRequest()) as [TaskTargetSet]
        let instances = try CDCoordinator.moc.fetch(TaskInstance.fetchRequest()) as [TaskInstance]
        XCTAssert(tasks.count == 0)
        XCTAssert(tags.count == 0)
        XCTAssert(targetSets.count == 0)
        XCTAssert(instances.count == 0)
    }
    
}
