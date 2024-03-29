//
//  AddTaskUITests.swift
//  MinteeUITests
//
//  UIT for the `AddTask` form.
//
//  The following UI elements are NOT tested
//  - Cancel button
//
//  Created by Vincent Young on 3/31/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils
@testable import Mintee

class AddTaskUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = .portrait
    }
    
    override func tearDown() {
        MOC_Validator.validate()
    }
    
}

// MARK: - Helper functions

extension AddTaskUITests {
    
    func navigate_to_AddTask() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
    }
    
    /**
     Adds a TaskTargetSet, assuming that AddTask is already navigated to
     */
    func add_TaskTargetSet(type: DayPattern.type, bubbles: [String]) {
        let app = XCUIApplication()
        app.scrollViews.otherElements.buttons["add-task-target-set-button"].tap()
        app.staticTexts["Add Target Set"].tap()
        app.staticTexts["day-bubble-monday"].tap()
        app.textFields["minimum-value"].tap()
        app.textFields["minimum-value"].typeText("2")
        app.buttons["task-target-set-popup-done-button"].tap()
    }
    
}

// MARK: - Done button tests

/*
 VDI:
    1. Task text field
    2. Tags
    3. Task type
        3a. Recurring
        3b. Specific
    4. Dates (Specific)
    5. TaskTargetSets (Recurring)
    6. Start and end date (Recurring)
 PCDI:
    1. Existing Tasks
    2. Existing Tags
 VDO: None
 PCDO:
    1. New Task in MOC
    2. Relationships with new Tags in MOC
    3. Relationships with existing Tags in MOC
    4. Relationships with new TaskInstances in MOC
 Combinations:
 VDI1
    - Empty
    - Non-empty
 VDI2
    - AddTagPopup integration tests
 VDI3
    - Task type button tests
 VDI4
    - No dates
    - Multiple dates with same day
    - Multiple dates with different dates
 VDI5
    - No TTSes
    - TaskTargetSet tests
 VDI6
    - One year apart
 PCDI1
    - Task with (name == VDI1) already exists
    - Task with (name == VDI1) does not exist
 PCDI2
    - Tag with (name == one of VDI2) already exists
    - Tag with (name == one of VDI2) does not already exist
 */
extension AddTaskUITests {}

// MARK: - AddTagPopup integration tests

extension AddTaskUITests {}

// MARK: - Task type button tests

/*
 VDI:
    1. Dates
    2. TaskTargetSets
 PCDI: None
 VDO:
    1. Dates already added and updated (when switching to `Specific`)
    2. TaskTargetSets already added and updated (when switching to `Recurring`)
 PCDO: None
 Combinations:
 VDI1
    - No dates added
    - Multiple dates added and edited
 VDI2
    - No TTSes added
    - TaskTargetSet tests
 */
extension AddTaskUITests {}

// MARK: - TaskTargetSet tests

/*
 Start and end date tests
 VDI:
    1. Start date
    2. End date
 PCDI: None
 VDO:
    1. Start date
    2. End date
 PCDO: None
 Combinations:
 VDI1
    - (== end date) -> (earlier)
    - (== end date) -> (later)
    - (earlier than end date) -> (==)
    - (earlier than end date) -> (later)
 VDI2
    - (== start date) -> (earlier)
    - (== start date) -> (later)
    - (later than end date) -> (==)
    - (later than end date) -> (earlier)
 */
extension AddTaskUITests {}

/*
 Integration with TaskTargetSetPopup for adding TaskTargetSets
 */
extension AddTaskUITests {}

/*
 Integration with TaskTargetSetPopup for editing TaskTargetSets
 VDI:
    1. Added TTSes
 PCDI: None
 VDO:
    1. Updated TTSes
 PCDO: None
 Combinations:
 VDI1
    - Lone TTS added
    - First TTS of multiple
    - Middle TTS of (>2)
    - Last TTS of multiple
 */
extension AddTaskUITests {}

/*
 Move up button tests
 VDI:
    1. Order of TTSes
 PCDI: None
 VDO:
    1. Order of TTSes
 PCDO: None
 Combinations:
 VDI1:
    - 1 TTS
    - First TTS of multiple
    - Middle TTS of (>2)
    - Last TTS of multiple
 */
extension AddTaskUITests {}

/*
 Move down button tests
 VDI:
    1. Order of TTSes
 PCDI: None
 VDO:
    1. Order of TTSes
 PCDO: None
 Combinations:
 VDI1:
    - 1 TTS
    - First TTS of multiple
    - Middle TTS of (>2)
    - Last TTS of multiple
 */
extension AddTaskUITests {}

/*
 Delete button tests
 VDI:
    1. Order of TTSes
    2. Count of TTSes
 PCDI: None
 VDO:
    1. Order of TTSes
    2. Count of TTSes
 PCDO: None
 Combinations:
 VDI1:
    - 1 TTS
    - First TTS of multiple
    - Middle TTS of (>2)
    - Last TTS of multiple
 */
extension AddTaskUITests {
}

// MARK: - Older tests

extension AddTaskUITests {
    
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
        
        app.buttons["task-target-set-popup-done-button"].tap()
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
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert(app.buttons["add-task-save-button"].isEnabled)
        
        XCTAssertFalse(app.staticTexts["add-task-error-message"].exists)
        app.buttons["add-task-save-button"].tap()
        XCTAssert(app.staticTexts["add-task-error-message"].label.count > 0)
        
    }
    
}
