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
import SwiftUI

class TagPopupUtils_Tests: XCTestCase {
    
    var tag: Tag!
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.teardownTestContainer()
    }
    
    func test_tagShouldBeDisplayed_sameContent_sameCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_sameContent_differentCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "TAG"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_contained() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag1" )
        XCTAssert(TagPopupUtils.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_sameCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(TagPopupUtils.tagShouldBeDisplayed(tag, "tag1"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_differentCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(TagPopupUtils.tagShouldBeDisplayed(tag, "TAG1"))
    }
    
}
