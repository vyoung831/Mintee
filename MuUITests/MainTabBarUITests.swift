//
//  MainTabBarUITests.swift
//  MuUITests
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest

class MainTabBarUITests: XCTestCase {

    let analysisTabName: String = "Analysis"
    let analysisNavBarName: String = "Analysis"
    let manageTabName :String = "Manage"
    let manageNavBarName :String = "Manage"
    let todayTabName :String = "Today"
    let todayNavBarName :String = "Today"
    let settingsTabName :String = "Settings"
    let settingsNavBarName :String = "Settings"
    
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
