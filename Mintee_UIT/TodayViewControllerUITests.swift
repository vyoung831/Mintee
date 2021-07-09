//
//  TodayViewControllerUITests.swift
//  MinteeUITests
//
//  This XCTestCase tests UI flows from TodayViewController
//
//  Created by Vincent Young on 4/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class TodayViewControllerUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = .portrait
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
        // TO-DO: Assert that SetDatePopup appears after popups have been integrated
    }
    
    func testTaskCardSelected() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        XCTAssert(app.navigationBars["Task Summary"].exists)
    }
    
    func testTaskCardEditButtonPressed() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        cell.buttons["Edit"].tap()
        XCTAssert(app.navigationBars["Edit Task"].exists)
    }
    
    func testTaskCardSetButtonPressed() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        cell.buttons["Set"].tap()
        // TO-DO: Assert that SetCountPopup appears after popups have been integrated
    }

}
