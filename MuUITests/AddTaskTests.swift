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
    
}
