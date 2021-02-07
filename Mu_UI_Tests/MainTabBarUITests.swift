//
//  MainTabBarUITests.swift
//  MuUITests
//
//  These UI tests test the navigation between Mu's main tabs
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class MainTabBarUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = .portrait
    }
    
    override func tearDown() { }
    
    func testNavigateToAnalysisTab() {
        let app = XCUIApplication()
        app.tabBars.buttons["Analysis"].tap()
        XCTAssert(app.navigationBars["Analysis"].exists)
    }
    
    func testNavigateToManageTab() {
        let app = XCUIApplication()
        app.tabBars.buttons["Manage"].tap()
        XCTAssert(app.navigationBars["Manage"].exists)
    }
    
    func testNavigateToTodayTab() {
        let app = XCUIApplication()
        app.tabBars.buttons["Today"].tap()
        XCTAssert(app.navigationBars["Today"].exists)
    }
    
    func testNavigateToSettingsTab() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
    }
    
}