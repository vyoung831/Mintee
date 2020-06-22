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
