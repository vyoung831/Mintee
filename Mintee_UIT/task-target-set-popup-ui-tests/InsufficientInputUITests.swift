//
//  InsufficientInputUITests.swift
//  MinteeUITests
//
//  Created by Vincent Young on 7/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class InsufficientInputUITests: XCTestCase {
    
    let insufficientInputErrorMessage: String = "Fill out at least either lower or upper target bound"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Launch the app, navigate to AddTask, and pull up TaskTargetSetPopup
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
        app.scrollViews.otherElements.buttons["add-task-target-set-button"].tap()
        
    }
    
    override func tearDownWithError() throws {
        MOC_Validator.validate()
    }
    
    /**
     Set TaskTargetSetPopup's pattern type picker value to Days of Month and verify the following:
     - A dow bubble must be selected for the popup's Done button to be enabled
     - Tapping the Done button without setting lower or upper values results in an error message being displayed
     */
    func testDow() throws {
        
        let app = XCUIApplication()
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
        // Toggle Monday and verify that Done button is enabled
        app.pickers["task-target-set-popup-pattern-type-picker"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Days of week")
        app.staticTexts["day-bubble-M"].tap()
        XCTAssert( app.buttons["task-target-set-popup-done-button"].isEnabled )
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        
        // Attempt to finish and verify that error message appears
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == insufficientInputErrorMessage )
        
    }
    
    /**
     Set TaskTargetSetPopup's pattern type picker value to Weekdays of Month and verify the following:
     - Both a dow and wom need to be selected in order for the Done button to be enabled
     - Tapping the Done button without setting lower or upper values results in an error message being displayed
     */
    func testWom() {
        
        let app = XCUIApplication()
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
        // Toggle Monday and verify that the Done button is disabled
        app.pickers["task-target-set-popup-pattern-type-picker"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Weekdays of month")
        app.staticTexts["day-bubble-M"].tap()
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        
        // Untoggle Monday and toggle 1st week of month, and verify that Done button is disabled
        app.staticTexts["day-bubble-M"].tap()
        app.staticTexts["day-bubble-1st"].tap()
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        
        // Toggle Monday again, attempt to finish, and verify that error message appears
        app.staticTexts["day-bubble-M"].tap()
        XCTAssert( app.buttons["task-target-set-popup-done-button"].isEnabled )
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == insufficientInputErrorMessage)
        
    }
    
    /**
     Set TaskTargetSetPopup's pattern type picker value to Days of Month and verify the following:
     - A dom bubble must be selected for the popup's Done button to be enabled
     - Tapping the Done button without setting lower or upper values results in an error message being displayed
     */
    func testDom() {
        
        let app = XCUIApplication()
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
        // Toggle 31 and verify that Done button is enabled
        app.pickers["task-target-set-popup-pattern-type-picker"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Days of month")
        app.staticTexts["day-bubble-31"].tap()
        XCTAssert( app.buttons["task-target-set-popup-done-button"].isEnabled )
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        
        // Attempt to finish and verify that error message appears
        app.buttons["task-target-set-popup-done-button"].tap()
        XCTAssert( app.staticTexts["task-target-set-popup-error-message"].label == insufficientInputErrorMessage)
        
    }
    
    /**
     Test that after selecting a dow bubble and verifying that the Done button is enabled, switching the pattern type disables the Done button
     */
    func testPatternTypeSwitch() {
        
        let app = XCUIApplication()
        XCTAssertFalse( app.staticTexts["task-target-set-popup-error-message"].exists )
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
        // Toggle Monday and verify that Done button is enabled
        app.staticTexts["day-bubble-M"].tap()
        XCTAssert( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
        // Switch pattern type to Weekdays of month and verify that Done button is disabled
        app.pickers["task-target-set-popup-pattern-type-picker"].pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Weekdays of month")
        XCTAssertFalse( app.buttons["task-target-set-popup-done-button"].isEnabled )
        
    }
    
}
