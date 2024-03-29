//
//  LowLessThanHighTests.swift
//  MinteeUITests
//
//  This class tests TaskTargetSetPopup input combinations where low value is less than the high value.
//
//  Created by Vincent Young on 7/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class LowLessThanHighTests: XCTestCase {
    
    let relationErrorMessage: String = "Please set max value greater than min value"
    let doubleEqualErrorMessage: String = "Only one operator can be set to ="
    
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
        
        app.textFields["minimum-value"].tap(); sleep(1)
        app.textFields["minimum-value"].typeText("1")
        app.textFields["maximum-value"].tap(); sleep(1)
        app.textFields["maximum-value"].typeText("2")
    }

    override func tearDownWithError() throws {
        MOC_Validator.validate()
    }

}

extension LowLessThanHighTests {
    
    func testLessThanLessThan() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. 1 < Target < 2")
        
    }
    
    func testLessThanLessThanOrEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. 1 < Target <= 2")
        
    }
    
    func testLessThanEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 2")
        
    }
    
    func testLessThanNA() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target > 1")
        
    }
    
}

// MARK: - Tests with lower operator set to [<=]

extension LowLessThanHighTests {
    
    func testLessThanOrEqualLessThan() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. 1 <= Target < 2")
        
    }
    
    func testLessThanOrEqualLessThanOrEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. 1 <= Target <= 2")
        
    }
    
    func testLessThanOrEqualEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 2")
        
    }
    
    func testLessThanOrEqualNA() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target >= 1")
        
    }
    
}

// MARK: - Tests with lower operator set to [=]

extension LowLessThanHighTests {
    
    func testEqualLessThan() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 1")
        
    }
    
    func testEqualLessThanOrEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 1")
        
    }
    
    func testEqualEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        
        // Attempt to finish and verify that error message appears
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == doubleEqualErrorMessage)
    }
    
    func testEqualNA() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 1")
        
    }
    
}

// MARK: - Tests with lower operator set to [N/A]

extension LowLessThanHighTests {
    
    func testNALessThan() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target < 2")
        
    }
    
    func testNALessThanOrEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "<=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target <= 2")
        
    }
    
    func testNAEqual() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "=")
        
        // Finish and verify that one TaskTargetSetView is added to AddTask with the correct accessibilityValue
        app.buttons["task-target-set-popup-done-button"].tap()
        let ttsvQuery = app.scrollViews.buttons.matching(identifier: "task-target-set-view")
        XCTAssert(ttsvQuery.count == 1)
        XCTAssert(ttsvQuery.allElementsBoundByIndex[0].value as! String == "Monday. Every week. Target = 2")
        
    }
    
    func testNANA() throws {
        
        let app = XCUIApplication()
        app.pickers["Low op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        app.pickers["High op"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "N/A")
        
        // Verify that the done button is disabled
        XCTAssertFalse(app.buttons["task-target-set-popup-done-button"].isEnabled)
        
    }
    
}

