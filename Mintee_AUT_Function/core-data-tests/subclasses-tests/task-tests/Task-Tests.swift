//
//  Task-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import XCTest
import CoreData

class Task_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
    // MARK: - Core Data Restraint tests
    
    /**
     Test that two Tasks with the same name can't be saved to the MOC
     */
    func test_restraint_taskNameUnique() {
        let task1 = Task(context: CDCoordinator.moc); task1._name = "Task"
        let task2 = Task(context: CDCoordinator.moc); task2._name = "Task"
        do { try CDCoordinator.moc.save() } catch {
            return
        }
        XCTFail()
    }
    
    // MARK: - Task deletion tests
    
    /**
     Test that deleteSelf successfully deletes a recurring-type Task, its Tags, its TaskInstances, and its TaskTargetSets
     */
    func test_deleteSelf_recurringTypeTask() throws {
        let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2019, month: 3, day: 1))!
        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc, min: 0, max: 3, minOperator: .lt, maxOperator: .lt, priority: 0,
                                    pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.sunday, .tuesday, . monday, .wednesday, .thursday, .friday]),
                                                        wom: Set<SaveFormatter.weekOfMonth>([]),
                                                        dom: Set<SaveFormatter.dayOfMonth>([])))
        
        let task = try Task(entity: Task.entity(),
                            insertInto: CDCoordinator.moc,
                            name: "Task",
                            tags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1"),
                                            try Tag.getOrCreateTag(tagName: "Tag2")]),
                            startDate: startDate, endDate: endDate,
                            targetSets: [tts])
        
        try task.deleteSelf()
        let tasks = try CDCoordinator.moc.fetch(Task.fetchRequest()) as [Task]
        let tags = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        let targetSets = try CDCoordinator.moc.fetch(TaskTargetSet.fetchRequest()) as [TaskTargetSet]
        let instances = try CDCoordinator.moc.fetch(TaskInstance.fetchRequest()) as [TaskInstance]
        XCTAssert(tasks.count == 0)
        XCTAssert(tags.count == 0)
        XCTAssert(targetSets.count == 0)
        XCTAssert(instances.count == 0)
    }
    
    /**
     Test that deleteSelf successfully deletes a specific-type Task, its Tags, and its TaskInstances
     */
    func test_deleteSelf_specificTypeTask() throws {
        let task = try Task(entity: Task.entity(),
                            insertInto: CDCoordinator.moc,
                            name: "Task",
                            tags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1"),
                                            try Tag.getOrCreateTag(tagName: "Tag2")]),
                            dates: [Date()])
        
        try task.deleteSelf()
        let tasks = try CDCoordinator.moc.fetch(Task.fetchRequest()) as [Task]
        let tags = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        let instances = try CDCoordinator.moc.fetch(TaskInstance.fetchRequest()) as [TaskInstance]
        XCTAssert(tasks.count == 0)
        XCTAssert(tags.count == 0)
        XCTAssert(instances.count == 0)
    }
    
}
