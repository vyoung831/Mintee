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

    override func setUpWithError() throws {
        Task_TagHandling_Tests_Util.setUp()
    }

    override func tearDownWithError() throws {
        MOC_Validator.validate()
        Task_TagHandling_Tests_Util.tearDown()
    }
    
    /**
     Test the time it takes updateTags to add 1,000 new Tags to the MOC
     */
    func testPerformance_updateTags_add1000() throws {
        
        var task: Task, tags: Set<Tag> = Set()
        task = Task(context: CDCoordinator.moc)
        for i in 1 ... 1000 {
            tags.insert( try Tag.getOrCreateTag(tagName: String(i)) )
        }
        
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
        for i in 1 ... 1000 {
            tags.insert( try Tag.getOrCreateTag(tagName: String(i)) )
        }
        task.updateTags(newTags: tags)
        
        self.measure {
            task.updateTags(newTags: Set())
        }
        
    }
    
}
