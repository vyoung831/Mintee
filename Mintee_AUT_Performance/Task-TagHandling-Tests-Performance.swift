//
//  Task_TagHandling_Tests_Performance.swift
//  Task_TagHandling_Tests_Performance
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import XCTest

class Task_TagHandling_Tests_Performance: XCTestCase {

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
     Test the time it takes updateTags to add 1,000 new Tags to the MOC
     */
    func testPerformance_updateTags_add1000() throws {
        
        var tags: Set<Tag> = Set()
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        for i in 1 ... 1000 {
            tags.insert( try Tag.getOrCreateTag(tagName: String(i), CDCoordinator.mainContext) )
        }
        
        self.measure {
            task.updateTags(newTags: tags, CDCoordinator.mainContext)
        }
        
    }
    
    /**
     Test the time it takes updateTags to delete 1,000 dead Tags from the MOC
     */
    func testPerformance_updateTags_delete1000() throws {
        
        var tags: Set<Tag> = Set()
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        for i in 1 ... 1000 {
            tags.insert( try Tag.getOrCreateTag(tagName: String(i), CDCoordinator.mainContext) )
        }
        task.updateTags(newTags: tags, CDCoordinator.mainContext)
        
        self.measure {
            task.updateTags(newTags: Set(), CDCoordinator.mainContext)
        }
        
    }
    
}
