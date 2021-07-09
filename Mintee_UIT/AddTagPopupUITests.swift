//
//  AddTagPopupUITests.swift
//  Mintee_UIT
//
//  UIT for the `AddTagPopup` form.
//
//  UI elements that are NOT tested
//  - Cancel button
//
//  Created by Vincent Young on 5/7/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class AddTagPopupUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

}

// MARK: - Helper functions

extension AddTagPopupUITests {}

// MARK: - Done button tests

/*
 VDI:
    1. Tag name text field
    2. Parent view's tags section
 PCDI: None
 VDO:
    1. Parent view's tags section
 PCDO: None
 Combinations:
 VDI1
    - Empty text field
    - Non-empty text field
 VDI2
    - Tag name text field content exists in parent view's tags section
    - Tag name text field content does not exist in parent view's tags section
 */
extension AddTagPopupUITests {
    
}

// MARK: - Tag list

/*
 Tags displayed in List
 VDI:
    1. Tag name text field
 PCDI:
    1. Tags in MOC
 VDO:
    1. Subset of Tags in MOC
 PCDO: None
 Combinations:
 VDI1
    - Empty text field
    - Non-empty text field
 PCDI1
    - No existing tags in MOC
    - Existing tags in MOC; no matching character sequence with Tag name text field
    - Existing tags in MOC; matching character sequence with Tag name text field (case mismatch)
    - Existing tags in MOC; matching character sequence with Tag name text field (case match)
 */
extension AddTagPopupUITests {
    
}

/*
 Tag List rows
 VDI:
    1. Tag name row
 PCDI: None
 VDO:
    1. Tag name text field
    2. Checkbox for selected Tag
 PCDO: None
 Combinations:
 VDI1
    - Tap a row
 */
extension AddTagPopupUITests {
    
}
