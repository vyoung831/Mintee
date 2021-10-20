//
//  Tag-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import XCTest
import CoreData

class Tag_Tests: XCTestCase {
    
    var task: Task!
    var analysis: Analysis!
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func setUpWithError() throws {
        task = try Task(entity: Task.entity(),
                        insertInto: CDCoordinator.mainContext,
                        name: "Task",
                        tags: Set(),
                        dates: [Date()])
        analysis = try Analysis(entity: Analysis.entity(),
                                insertInto: CDCoordinator.mainContext,
                                name: "Analysis",
                                type: .box,
                                dateRange: 0,
                                legend: AnalysisLegend(categorizedEntries: Set(), completionEntries: Set([CompletionLegendEntry(color: .blue, min: 0, max: 1, minOperator: .lt, maxOperator: .lt)])),
                                order: 0,
                                tags: Set())
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
}

// MARK: - associateTags tests (Task)

extension Tag_Tests {
    
    /**
     Test that associateTags creates a new Tag if one doesn't already exist
     */
    func test_associateTags_newTag() throws {
        var tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 0)
        
        try Tag.associateTags(tagNames: Set(["Tag"]), task, CDCoordinator.mainContext)
        tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
    }
    
    /**
     Test that associateTags doesn't create new Tags when an existing tagName is requested
     */
    func test_associateTags_reuseExisting() throws {
        try Tag.associateTags(tagNames: Set(["Tag"]), task, CDCoordinator.mainContext)
        var tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        try Tag.associateTags(tagNames: Set(["Tag"]), task, CDCoordinator.mainContext)
        tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
    }
    
}

// MARK: - associateTags tests (Analysis)

extension Tag_Tests {
    
    func test_associateTags_nonExistingTag() throws {
        XCTAssertThrowsError(try Tag.associateTags(tagNames: Set(["Tag"]), analysis, CDCoordinator.mainContext))
    }
    
    func test_associateTags_existingTag() throws {
        try Tag.associateTags(tagNames: Set(["Tag"]), task, CDCoordinator.mainContext)
        try Tag.associateTags(tagNames: Set(["Tag"]), analysis, CDCoordinator.mainContext)
    }
    
}
