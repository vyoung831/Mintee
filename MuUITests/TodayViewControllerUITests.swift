//
//  TodayViewControllerUITests.swift
//  MuUITests
//
//  This XCTestCase tests UI flows from TodayViewController
//
//  Created by Vincent Young on 4/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class TodayViewControllerUITests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchButtonPressed() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        let todayNavigationBar = app.navigationBars["Today"]
        todayNavigationBar.buttons["Search"].tap()
        XCTAssert(app.navigationBars["Set Filter"].exists)
    }
    
    func testAddButtonPressed() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        let todayNavigationBar = app.navigationBars["Today"]
        todayNavigationBar.buttons["Add"].tap()
        XCTAssert(app.navigationBars["Add Task"].exists)
    }
    
    func testDateButtonPressed() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        let todayNavigationBar = app.navigationBars["Today"]
        todayNavigationBar.buttons["Date"].tap()
        // TO-DO: Assert that SelectDatePopup appears after integrating popup
    }
    
    func testTaskCardSelected() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.tap()
        XCTAssert(app.navigationBars["Task Summary"].exists)
    }

}
