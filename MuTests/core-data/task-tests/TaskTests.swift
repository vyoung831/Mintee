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

class TaskTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - Constraint tests
    
    /**
     Test that two Tasks with the same name can't be saved to the MOC
     */
    func testTasksSameName() {
        let task1 = Task(context: CDCoordinator.moc); task1.name = "Task"
        let task2 = Task(context: CDCoordinator.moc); task2.name = "Task"
        do { try CDCoordinator.moc.save() } catch {
            return
        }
        XCTFail()
    }
    
    // MARK: - updateTags tests
    
    /**
     Test the following updateTags() functions
     1. New Tags are created and added to the MOC
     2. Existing Tags are re-used
     3. Dead Tags are deleted
     */
    func testUpdateTags() throws {
        
        var tags: [Tag] = []
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 0)
        
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTagNames: ["Tag1","Tag2"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 2)
        
        task.updateTags(newTagNames: ["Tag1","Tag2","Tag3"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 3)
        
        task.updateTags(newTagNames: ["Tag2","Tag3"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 2)
        
    }
    
    /**
     Test that updateDates updates the Task's dates and saves in the expected String format
     */
    func testUpdateDates() {
        
        let task = Task(context: CDCoordinator.moc)
        XCTAssert(task.startDate == nil)
        XCTAssert(task.endDate == nil)
        
        // Start date = GMT April 17, 1998 13:49:35
        // End date = GMT December 5, 1998 01:22:55
        let startDate = Date(timeIntervalSince1970: 892820975)
        let endDate = Date(timeIntervalSince1970: 912820975)
        let startDay = String(format: "%02d", Calendar.current.component(.day, from: startDate))
        let endDay = String(format: "%02d", Calendar.current.component(.day, from: endDate))
        let startDateString = "1998-04-\(startDay)"
        let endDateString = "1998-12-\(endDay)"
        
        task.updateDates(startDate: startDate, endDate: endDate)
        XCTAssert(task.startDate == startDateString)
        XCTAssert(task.endDate == endDateString)
        
    }
    
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

// MARK: - Performance tests

extension TaskTests {
    
    /**
     Test the time it takes updateTags to add 1,000 new Tags to the MOC
     */
    func testPerformanceAddNewTags() throws {
        
        var task: Task, tags: [String] = []
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 { tags.append(String(i)) }
        
        self.measure {
            task.updateTags(newTagNames: tags)
        }
        
    }
    
    /**
     Test the time it takes updateTags to delete 1,000 dead Tags from the MOC
     */
    func testPerformanceRemoveTags() throws {
        
        var task: Task, tags: [String] = []
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 { tags.append(String(i)) }
        task.updateTags(newTagNames: tags)
        
        self.measure {
            task.updateTags(newTagNames: [])
        }
        
    }
    
}
