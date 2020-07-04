//
//  AddTaskTests.swift
//  MuUITests
//
//  Created by Vincent Young on 3/31/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class AddTaskTests: XCTestCase {
    
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
     */
    func testNavigateToAddTask() {
        
        // Navigate to Today and to AddTask
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["plus.circle"].tap()
        
        // Check that fields/sections are blank or empty
        XCTAssert(app.otherElements.textFields["Task name"].label.count == 0)
        XCTAssert(app.descendantsSet(matching: .any, identifier: "tag").count == 0)
        XCTAssert(app.descendantsSet(matching: .any, identifier: "task-target-set").count == 0)
        
    }
    
}
