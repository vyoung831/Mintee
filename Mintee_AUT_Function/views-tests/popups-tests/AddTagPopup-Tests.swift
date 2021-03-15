//
//  AddTagPopup-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
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
        let addTagPopup = AddTagPopup(isBeingPresented: self.$ibp, tagText: "tag", errorMessage: "", addTag: {_ in return ""})
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(addTagPopup.tagShouldBeDisplayed(tag))
    }
    
    func test_tagShouldBeDisplayed_sameContent_differentCase() throws {
        let addTagPopup = AddTagPopup(isBeingPresented: self.$ibp, tagText: "TAG", errorMessage: "", addTag: {_ in return ""})
        tag = try Tag.getOrCreateTag( tagName: "tag" )
        XCTAssert(addTagPopup.tagShouldBeDisplayed(tag))
    }
    
    func test_tagShouldBeDisplayed_differentContent_contained() throws {
        let addTagPopup = AddTagPopup(isBeingPresented: self.$ibp, tagText: "tag", errorMessage: "", addTag: {_ in return ""})
        tag = try Tag.getOrCreateTag( tagName: "tag1" )
        XCTAssert(addTagPopup.tagShouldBeDisplayed(tag))
    }
    
    func test_tagShouldBeDisplayed_differentContent_sameCase() throws {
        let addTagPopup = AddTagPopup(isBeingPresented: self.$ibp, tagText: "tag1", errorMessage: "", addTag: {_ in return ""})
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(addTagPopup.tagShouldBeDisplayed(tag))
    }
    
    func test_tagShouldBeDisplayed_differentContent_differentCase() throws {
        let addTagPopup = AddTagPopup(isBeingPresented: self.$ibp, tagText: "TAG1", errorMessage: "", addTag: {_ in return ""})
        tag = try Tag.getOrCreateTag( tagName: "tag2" )
        XCTAssertFalse(addTagPopup.tagShouldBeDisplayed(tag))
    }
    
}
