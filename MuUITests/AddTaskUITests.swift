//
//  AddTaskUITests.swift
//  MuUITests
//
//  Created by Vincent Young on 3/31/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class AddTaskUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = .portrait
    }
    
    override func tearDown() {}
    
    /**
     Navigate to AddTask and verify that
     - Task name text field is empty
     - No Tags exist
     - No TaskTargetSets exist
     - Save button is disabled
     */
    func testNavigateToAddTask() {
        
        // Navigate to Today and to AddTask
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        
        // Check that fields/sections are blank or empty
        // TO-DO: Change test to get the text field's value that is NOT placeholder
        XCTAssert((app.otherElements.textFields["task-name-text-field"].value as! String) == "Task name")
        XCTAssert(app.descendantsSet(matching: .any, identifier: "tag").count == 0)
        XCTAssert(app.descendantsSet(matching: .any, identifier: "task-target-set").count == 0)
        XCTAssert(!app.buttons["add-task-save-button"].isEnabled)
        
    }
    
    /**
     Navigate to AddTask, and confirm that save is disabled after completing the following
     - Leave task name text field empty
     - Leave task type unselected
     - Add 1 TaskTargetSet
     */
    func testSaveButtonOneTargetSet() {
        
        // Navigate to Today and to AddTask
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        app.scrollViews.otherElements.buttons["add-task-target-set-button"].tap()
        
        // Add a TaskTargetSet and confirm that save is disabled
        app.staticTexts["Add Target Set"].tap()
        app.staticTexts["day-bubble-M"].tap()
        
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        
        app/*@START_MENU_TOKEN@*/.buttons["add-target-set-done-button"]/*[[".buttons[\"Done\"]",".buttons[\"add-target-set-done-button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(!app.buttons["add-task-save-button"].isEnabled)
        
    }
    
    /**
     Navigate to AddTask, and confirm that save is enabled after completing the following
     - Enter a task name
     - Leave task type unselected
     - Leave TaskTargetSet count as empty
     Then attempt to save and check that AddTask displays an error message
     */
    func testSaveButtonName() {
        
        // Navigate to Today and to AddTask
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        
        app.otherElements.textFields["task-name-text-field"].tap()
        app.otherElements.textFields["task-name-text-field"].typeText("Name")
        XCTAssert(app.buttons["add-task-save-button"].isEnabled)
        
        XCTAssertFalse(app.staticTexts["add-task-error-message"].exists)
        app.buttons["add-task-save-button"].tap()
        XCTAssert(app.staticTexts["add-task-error-message"].label.count > 0)
        
    }
    
    /**
     Navigate to AddTask, and confirm that save is enabled after completing the following
     - Enter a task name
     - Leave task type unselected
     - Add 1 TaskTargetSet
     Then attempt to save and check that AddTask displays an error message (Because no task type was selected)
     */
    func testSaveButtonNameOneTargetSet() {
        
        // Navigate to Today and to AddTask
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        
        // Set the task name
        app.otherElements.textFields["task-name-text-field"].tap()
        app.otherElements.textFields["task-name-text-field"].typeText("Name")
        
        // Add a TaskTargetSet
        app.scrollViews.otherElements.buttons["add-task-target-set-button"].tap()
        app.staticTexts["Add Target Set"].tap()
        app.staticTexts["day-bubble-M"].tap()
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app/*@START_MENU_TOKEN@*/.buttons["add-target-set-done-button"]/*[[".buttons[\"Done\"]",".buttons[\"add-target-set-done-button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(app.buttons["add-task-save-button"].isEnabled)
        
        XCTAssertFalse(app.staticTexts["add-task-error-message"].exists)
        app.buttons["add-task-save-button"].tap()
        XCTAssert(app.staticTexts["add-task-error-message"].label.count > 0)
        
    }
    
}
