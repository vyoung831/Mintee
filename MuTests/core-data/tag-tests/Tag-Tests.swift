//
//  TagTests.swift
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
    func testGetOrCreateTagNew() throws {
        
        var tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 0)
        
        let _ = Tag.getOrCreateTag(tagName: "Tag")
        tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
    }
    
    /**
     Test that getOrCreateTag doesn't create new Tags when an existing tagName is requested
     */
    func testGetOrCreateTagExisting() throws {
        
        let tag1 = Tag(entity: Tag.getEntityDescription(CDCoordinator.moc)!, insertInto: CDCoordinator.moc); tag1.name = "Tag"
        var tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        let _ = Tag.getOrCreateTag(tagName: "Tag")
        tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
    }
    
}

// MARK: - Core Data Restraint tests

extension Tag_Tests {
    
    /**
     Test uniqueness of Tag's name
     */
    func testTagNameRestraint() {
        
        let tag1 = Tag(entity: Tag.getEntityDescription(CDCoordinator.moc)!, insertInto: CDCoordinator.moc); tag1.name = "Tag"
        let tag2 = Tag(entity: Tag.getEntityDescription(CDCoordinator.moc)!, insertInto: CDCoordinator.moc); tag2.name = "Tag"
        do {
            try CDCoordinator.moc.save()
            XCTFail()
        } catch {
            // Succeeded
        }
        
    }
    
}
