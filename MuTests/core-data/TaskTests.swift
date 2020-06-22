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
        CDCoordinator.moc.rollback()
    }
    
    override func tearDownWithError() throws { }
    
    /**
     Test the following updateTags() functions
     1. New Tags are created and added to the MOC
     2. Existing Tags are re-used
     3. Dead Tags are deleted
     */
    func testUpdateTags() throws {
        
        var task: Task
        var tags: [Tag] = []
        do {
            try tags = CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        } catch {
            exit(-1)
        }
        XCTAssert(tags.count == 0)
        
        task = Task(context: CDCoordinator.moc)
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
    
}
