//
//  AddTagPopupUITests.swift
//  Mintee_UIT
//
//  UIT for the `AddTagPopup` form.
//
//  UI elements that are NOT tested
//  - Cancel button
//
//  Created by Vincent Young on 5/7/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class AddTagPopupUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
}

// MARK: - Helper functions

extension AddTagPopupUITests {
    
    static let TagViewPredicate: NSPredicate = NSPredicate(format: "identifier MATCHES 'TagView-.*'")
    
    // Navigates to (AddTask -> AddTagPopup) from one of the main tab bar views
    static func navigateToAddTagPopup() {
        AddTaskUITests.navigate_to_AddTask()
        let app = XCUIApplication()
        app.scrollViews.otherElements.buttons["add-tag-button"].tap()
    }
    
    // Types a String into AddTagPopup's TextField and presses the `Done` button.
    static func typeTagName_pressDone(_ tagName: String) {
        let app = XCUIApplication()
        app.textFields["add-tag-popup-text-field"].tap()
        app.typeText(tagName)
        app.buttons["add-tag-popup-done-button"].tap()
    }
    
}

// MARK: - Done button tests

/*
 VDI:
    1. Tag name text field
    2. Parent view's tags section
 PCDI: None
 VDO:
    1. Parent view's tags section
 PCDO: None
 Combinations:
 VDI1
    1. Empty text field
    2. Non-empty text field
 VDI2
    1. Tag name text field content exists in parent view's tags section (matching case)
    2. Tag name text field content exists in parent view's tags section (non-matching case)
    3. Tag name text field content does not exist in parent view's tags section
 */
extension AddTagPopupUITests {
    
    // VDI1(1), VDI2(1) - Not implemented - TagsSection should not be allowed to have empty tags
    // VDI1(1), VDI2(2) - Not implemented - TagsSection should not be allowed to have empty tags
    func test_doneButton_emptyTagName_parentViewContains_matchingCase() {}
    func test_doneButton_emptyTagName_parentViewContains_nonMatchingCase() {}
    
    // VDI1(1), VDI2(3)
    func test_doneButton_emptyTagName_parentViewDoesNotContain() {
        AddTagPopupUITests.navigateToAddTagPopup()
        AddTagPopupUITests.typeTagName_pressDone("")
        let app = XCUIApplication()
        XCTAssert(app.scrollViews.otherElements.staticTexts.matching(AddTagPopupUITests.TagViewPredicate).count == 0)
    }
    
    // VDI1(2), VDI2(1)
    func test_doneButton_nonEmptyTagName_parentViewContains_matchingCase() {
        
        // Add a tag with name "Test tag"
        test_doneButton_nonEmptyTagName_parentViewDoesNotContain()
        
        // Attempt to re-add "Test tag"
        let app = XCUIApplication()
        app.scrollViews.otherElements.buttons["add-tag-button"].tap()
        XCTAssertFalse(app.staticTexts["AddTagPopup-error-message"].exists)
        AddTagPopupUITests.typeTagName_pressDone("Test tag")
        XCTAssert(app.staticTexts["AddTagPopup-error-message"].exists)
        
        // Cancel out and confirm that still, only 1 TagView exists
        app.buttons["add-tag-popup-cancel-button"].tap()
        XCTAssert(app.scrollViews.otherElements.staticTexts.matching(AddTagPopupUITests.TagViewPredicate).count == 1)
        
    }
    
    // VDI1(2), VDI2(2)
    func test_doneButton_nonEmptyTagName_parentViewContains_nonMatchingCase() {
        
        // Add a tag with name "Test tag"
        test_doneButton_nonEmptyTagName_parentViewDoesNotContain()
        
        // Attempt to re-add "test tag" with lowercase "test"
        let app = XCUIApplication()
        app.scrollViews.otherElements.buttons["add-tag-button"].tap()
        XCTAssertFalse(app.staticTexts["AddTagPopup-error-message"].exists)
        AddTagPopupUITests.typeTagName_pressDone("test tag")
        XCTAssert(app.staticTexts["AddTagPopup-error-message"].exists)
        
        // Cancel out and confirm that still, only 1 TagView exists
        app.buttons["add-tag-popup-cancel-button"].tap()
        XCTAssert(app.scrollViews.otherElements.staticTexts.matching(AddTagPopupUITests.TagViewPredicate).count == 1)
        
    }
    
    // VDI1(2), VDI2(2)
    func test_doneButton_nonEmptyTagName_parentViewDoesNotContain() {
        AddTagPopupUITests.navigateToAddTagPopup()
        AddTagPopupUITests.typeTagName_pressDone("Test tag")
        
        // Confirm that only 1 expected TagView exists
        let app = XCUIApplication()
        XCTAssert(app.scrollViews.otherElements.staticTexts["TagView-Test tag"].exists)
        XCTAssert(app.scrollViews.otherElements.staticTexts.matching(AddTagPopupUITests.TagViewPredicate).count == 1)
    }
    
}

// MARK: - Tag list

/*
 Tags displayed in List
 VDI:
    1. Tag name text field
 PCDI:
    1. Tags in MOC
 VDO:
    1. Subset of Tags in MOC
 PCDO: None
 Combinations:
 VDI1
    - Empty text field
    - Non-empty text field
 PCDI1
    - No existing tags in MOC
    - Existing tags in MOC; no matching character sequence with Tag name text field
    - Existing tags in MOC; matching character sequence with Tag name text field (case mismatch)
    - Existing tags in MOC; matching character sequence with Tag name text field (case match)
 */
extension AddTagPopupUITests {
    
}

/*
 Tag List rows
 VDI:
    1. Tag name row
 PCDI: None
 VDO:
    1. Tag name text field
    2. Checkbox for selected Tag
 PCDO: None
 Combinations:
 VDI1
    - Tap a row
 */
extension AddTagPopupUITests {
    
}
