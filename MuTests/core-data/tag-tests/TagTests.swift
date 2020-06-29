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

class TagTests: XCTestCase {
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
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
    
    /**
     Test that getOrCreateTag doesn't create new Tags when an existing tagName is requested
     */
    func testTagReused() throws {
        
        let tag1 = Tag(entity: Tag.getEntityDescription(CDCoordinator.moc)!, insertInto: CDCoordinator.moc); tag1.name = "Tag"
        var tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
        let tag2 = Tag.getOrCreateTag(tagName: "Tag")
        tagFetch = try CDCoordinator.moc.fetch(Tag.fetchRequest()) as [Tag]
        XCTAssert(tagFetch.count == 1)
        
    }
    
}
