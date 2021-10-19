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
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
}

// MARK: - getOrCreateTag tests

extension Tag_Tests {
    
    /**
     Test that getOrCreateTag creates a new Tag if one doesn't already exist
     */
    func test_getOrCreateTag_newTag() throws {
        
        var tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 0)
        
        let _ = try Tag.getOrCreateTag(tagName: "Tag", CDCoordinator.mainContext)
        tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
    }
    
    /**
     Test that getOrCreateTag doesn't create new Tags when an existing tagName is requested
     */
    func test_getOrCreateTag_reuseExisting() throws {
        
        let tag1 = try Tag.getOrCreateTag(tagName: "Tag", CDCoordinator.mainContext)
        var tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        let tag2 = try Tag.getOrCreateTag(tagName: "Tag", CDCoordinator.mainContext)
        tagFetch = try CDCoordinator.mainContext.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        XCTAssert(tag1 == tag2)
        
    }
    
}

// MARK: - getTag	 tests

extension Tag_Tests {
    
    func test_getTag_nonExistingTag() throws {
        
        let tag = try Tag.getTag(tagName: "Tag", CDCoordinator.mainContext)
        XCTAssert(tag == nil)
        
    }
    
    func test_getTag_existingTag() throws {
        
        let _ = try Tag.getOrCreateTag(tagName: "Tag", CDCoordinator.mainContext)
        let tag = try Tag.getTag(tagName: "Tag", CDCoordinator.mainContext)
        XCTAssert(tag != nil)
        
    }
    
}
