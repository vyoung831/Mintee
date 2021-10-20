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
        
        var tagNames: Set<String> = Set()
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        
        for i in 1 ... 1000 {
            tagNames.insert(String(i))
        }
        
        self.measure {
            try! task.updateTags(newTagNames: tagNames, CDCoordinator.mainContext)
        }
        
    }
    
    /**
     Test the time it takes updateTags to delete 1,000 dead Tags from the MOC
     */
    func testPerformance_updateTags_delete1000() throws {
        
        var tagNames: Set<String> = Set()
        let task = try! Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext,
                             name: "Task", tags: Set(), dates: [])
        for i in 1 ... 1000 {
            tagNames.insert(String(i))
        }
        try task.updateTags(newTagNames: tagNames, CDCoordinator.mainContext)
        
        self.measure {
            try! task.updateTags(newTagNames: tagNames, CDCoordinator.mainContext)
        }
        
    }
    
}
