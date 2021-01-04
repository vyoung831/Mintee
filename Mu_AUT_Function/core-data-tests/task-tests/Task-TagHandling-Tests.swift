//
//  Task-TagHandling-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 9/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
@testable import SharedTestUtils
import CoreData
import XCTest

class Task_TagHandling_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    /**
     Test that updateTags() adds new Tags where if none with the same name already exist
     */
    func test_updateTags_addNewTags() throws {
        var tags: [Tag] = []
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!,
                                           Tag.getOrCreateTag(tagName: "Tag2")!]))
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
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
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!,
                                           Tag.getOrCreateTag(tagName: "Tag2")!]))
        task.updateTags(newTags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!,
                                           Tag.getOrCreateTag(tagName: "Tag2")!,
                                           Tag.getOrCreateTag(tagName: "Tag3")!]))
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
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
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!,
                                           Tag.getOrCreateTag(tagName: "Tag2")!,
                                           Tag.getOrCreateTag(tagName: "Tag3")!]))
        task.updateTags(newTags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!,
                                           Tag.getOrCreateTag(tagName: "Tag2")!]))
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            XCTFail()
        }
        XCTAssert(tags.count == 2)
    }
    
}

// MARK: - Performance tests

extension Task_TagHandling_Tests {
    
    /**
     Test the time it takes updateTags to add 1,000 new Tags to the MOC
     */
    func testPerformance_updateTags_add1000() throws {
        
        var task: Task, tags: Set<Tag> = Set()
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 { tags.insert( Tag.getOrCreateTag(tagName: String(i))! ) }
        
        self.measure {
            task.updateTags(newTags: tags)
        }
        
    }
    
    /**
     Test the time it takes updateTags to delete 1,000 dead Tags from the MOC
     */
    func testPerformance_updateTags_delete1000() throws {
        
        var task: Task, tags: Set<Tag> = Set()
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 { tags.insert( Tag.getOrCreateTag(tagName: String(i))! ) }
        task.updateTags(newTags: tags)
        
        self.measure {
            task.updateTags(newTags: Set())
        }
        
    }
    
}

