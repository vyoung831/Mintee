//
//  InputValidationUITests.swift
//  MuUITests
//
//  These UI tests verify that TaskTargetSetPopup does one of the following
//  - Provides the user with an error message when attempting to add a target set with invalid input
//  - Adds a target set with the correct label, frequency, and values
//
//  Created by Vincent Young on 7/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class InputValidationUITests: XCTestCase {
    
    let relationErrorMessage: String = "Please set max value greater than min value"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Launch the app, navigate to AddTask, and pull up TaskTargetSetPopup
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        app.scrollViews.otherElements.buttons["add-task-target-set-button"].tap()
        
        // Select Monday as a day of week
        app.pickers["task-target-set-popup-pattern-type-picker"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Days of week")
        app.staticTexts["day-bubble-M"].tap()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK:- Tests with both operators set to [less than]
    
    func testLessThanLessThanLowOnly() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app.buttons["task-target-set-popup-done-button"].tap()
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the current accessibilityValue
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target > 2")
        
    }
    
    func testLessThanLessThanHighOnly() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.textFields["maximum-value"].tap()
        app.textFields["maximum-value"].typeText("3")
        app.buttons["task-target-set-popup-done-button"].tap()
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the current accessibilityValue
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target < 3")
        
    }
    
    func testLessThanLessThanLowLessThanHigh() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app.textFields["maximum-value"].tap()
        app.textFields["maximum-value"].typeText("3")
        app.buttons["task-target-set-popup-done-button"].tap()
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the current accessibilityValue
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. 2 < Target < 3")
        
    }
    
    func testLessThanLessThanLowEqualToHigh() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app.textFields["maximum-value"].tap()
        app.textFields["maximum-value"].typeText("2")
        
        // Attempt to finish and verify that error message appears
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == relationErrorMessage)
        
    }
    
    func testLessThanLessThanLowGreaterThanHigh() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app.textFields["maximum-value"].tap()
        app.textFields["maximum-value"].typeText("2")
        
        // Attempt to finish and verify that error message appears
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == relationErrorMessage)
        
    }
    
}
