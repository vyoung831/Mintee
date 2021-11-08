//
//  TagPopupUtils-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import XCTest

class TagPopupUtils_Tests: XCTestCase {
    
    var task: Task!
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func setUpWithError() throws {
        task = try Task(entity: Task.entity(), insertInto: CDCoordinator.mainContext, name: "Task", tags: Set(), dates: [Date()])
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
    func test_tagShouldBeDisplayed_sameContent_sameCase() throws {
        try task.updateTags(newTagNames: Set(["tag"]), CDCoordinator.mainContext)
        let tag = try CDCoordinator.mainContext.fetch(Tag.fetchRequest())[0]
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_sameContent_differentCase() throws {
        try task.updateTags(newTagNames: Set(["tag"]), CDCoordinator.mainContext)
        let tag = try CDCoordinator.mainContext.fetch(Tag.fetchRequest())[0]
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "TAG"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_contained() throws {
        try task.updateTags(newTagNames: Set(["tag1"]), CDCoordinator.mainContext)
        let tag = try CDCoordinator.mainContext.fetch(Tag.fetchRequest())[0]
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_sameCase() throws {
        try task.updateTags(newTagNames: Set(["tag2"]), CDCoordinator.mainContext)
        let tag = try CDCoordinator.mainContext.fetch(Tag.fetchRequest())[0]
        XCTAssertFalse(TagPopupUtils.tagShouldBeDisplayed(tag, "tag1"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_differentCase() throws {
        try task.updateTags(newTagNames: Set(["tag2"]), CDCoordinator.mainContext)
        let tag = try CDCoordinator.mainContext.fetch(Tag.fetchRequest())[0]
        XCTAssertFalse(TagPopupUtils.tagShouldBeDisplayed(tag, "TAG1"))
    }
    
}
