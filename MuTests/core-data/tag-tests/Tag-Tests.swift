//
//  Tag-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 6/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class Tag_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    /**
     Test that getOrCreateTag creates a new Tag if one doesn't already exist
     */
    func test_getOrCreateTag_newTag() throws {
        
        var tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 0)
        
        let _ = Tag.getOrCreateTag(tagName: "Tag")
        tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
    }
    
    /**
     Test that getOrCreateTag doesn't create new Tags when an existing tagName is requested
     */
    func test_getOrCreateTag_reuseExisting() throws {
        
        let tag1 = Tag.getOrCreateTag(tagName: "Tag")
        var tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        let tag2 = Tag.getOrCreateTag(tagName: "Tag")
        tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        XCTAssert(tag1 == tag2)
        
    }
    
}
