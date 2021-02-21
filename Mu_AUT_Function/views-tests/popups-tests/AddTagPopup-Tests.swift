//
//  AddTagPopup-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 9/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
@testable import SharedTestUtils
import XCTest
import SwiftUI

class AddTagPopup_Tests: XCTestCase {
    
    @State var ibp: Bool = true
    var tag: Tag!
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    func test_tagShouldBeDisplayed_sameContent_sameCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(AddTagPopup.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_sameContent_differentCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(AddTagPopup.tagShouldBeDisplayed(tag, "TAG"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_contained() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag1" )
        XCTAssert(AddTagPopup.tagShouldBeDisplayed(tag, "tag"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_sameCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(AddTagPopup.tagShouldBeDisplayed(tag, "tag1"))
    }
    
    func test_tagShouldBeDisplayed_differentContent_differentCase() throws {
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(AddTagPopup.tagShouldBeDisplayed(tag, "TAG1"))
    }
    
}
