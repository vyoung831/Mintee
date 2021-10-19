//
//  Task-TagHandling-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import CoreData
import XCTest

class Task_TagHandling_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func setUpWithError() throws {
        Task_TagHandling_Tests_Util.setUp()
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
    /**
     Test that updateTags() adds new Tags where if none with the same name already exist
     */
    func test_updateTags_addNewTags() throws {
        var tags: [Tag] = []
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        task.updateTags(newTags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag2", CDCoordinator.mainContext)]),
                        CDCoordinator.mainContext)
        do {
            try tags = CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            XCTFail()
        }
        XCTAssert(tags.count == 2)
    }
    
    /**
     Test that updateTags() reuses Tags with the same name
     */
    func test_updateTags_existingTagReuse() throws {
        var tags: [Tag] = []
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        task.updateTags(newTags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag2", CDCoordinator.mainContext)]),
                        CDCoordinator.mainContext)
        task.updateTags(newTags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag2", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag3", CDCoordinator.mainContext)]),
                        CDCoordinator.mainContext)
        do {
            try tags = CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            XCTFail()
        }
        XCTAssert(tags.count == 3)
    }
    
    /**
     Test that updateTags() deletes any newly-unassociated Tags that are no longer associated with any Task
     */
    func test_updateTags_deadTagDeletion() throws {
        var tags: [Tag] = []
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        task.updateTags(newTags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag2", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag3", CDCoordinator.mainContext)]),
                        CDCoordinator.mainContext)
        task.updateTags(newTags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1", CDCoordinator.mainContext),
                                           try Tag.getOrCreateTag(tagName: "Tag2", CDCoordinator.mainContext)]),
                        CDCoordinator.mainContext)
        do {
            try tags = CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            XCTFail()
        }
        XCTAssert(tags.count == 2)
    }
    
}
