//
//  TaskTagHandlingTests.swift
//  MuTests
//
//  Created by Vincent Young on 9/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import CoreData
import XCTest

class Task_TagHandlingTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    /**
     Test that updateTags() adds new Tags where if none with the same name already exist
     */
    func testUpdateTags_addNewTags() throws {
        var tags: [Tag] = []
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTagNames: ["Tag1","Tag2"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 2)
    }
    
    /**
     Test that updateTags() reuses Tags with the same name
     */
    func testUpdateTags_existingTagReuse() throws {
        var tags: [Tag] = []
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTagNames: ["Tag1","Tag2"])
        task.updateTags(newTagNames: ["Tag1","Tag2","Tag3"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 3)
    }
    
    /**
     Test that updateTags() deletes any newly-unassociated Tags that are no longer associated with any Task
     */
    func testUpdateTags_deadTagDeletion() throws {
        var tags: [Tag] = []
        let task = Task(context: CDCoordinator.moc)
        task.updateTags(newTagNames: ["Tag1","Tag2","Tag3"])
        task.updateTags(newTagNames: ["Tag1","Tag2"])
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 2)
    }
    
}

// MARK: - Performance tests

extension Task_TagHandlingTests {
    
    /**
     Test the time it takes updateTags to add 1,000 new Tags to the MOC
     */
    func testUpdateTagsAdd1000() throws {
        
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
    func testUpdateTagsDelete1000() throws {
        
        var task: Task, tags: [String] = []
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 { tags.append(String(i)) }
        task.updateTags(newTagNames: tags)
        
        self.measure {
            task.updateTags(newTagNames: [])
        }
        
    }
    
}

