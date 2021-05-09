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

class AddTagPopupUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {}

}

// MARK: - Helper functions

extension AddTagPopupUITests: XCTestCase {
    
}

// MARK: - Done button tests

/*
 VDI:
    1. Tag name text field
 PSDI: None
 VDO:
    1. Parent view's tags section
 PSDO: None
 1. Empty text field; tag does not exist in parent view's tags section
 2. Empty text field; tag exists in parent view's tags section
 3. Non-empty text field; tag does not exist in parent view's tags section
 4. Non-empty text field; tag exists in parent view's tags section
 */
extension AddTagPopupUITests: XCTestCase {
    
}

// MARK: - Tag list

/*
 Tag List
 VDI: Tag name text field
 PSDI: Tags in MOC
 VDO: Subset of Tags in MOC; checkbox for selected Tag
 PSDO: None
 1. Empty text field; no existing tags in MOC
 2. Empty text field; existing tags in MOC
 3. Non-empty text field and existing tags in MOC; no matching character sequence
 4. Non-empty text field and existing tags in MOC; matching character sequence
    a. Case mismatches
 */
extension AddTagPopupUITests: XCTestCase {
    
}

/*
 Tag List rows
 VDI: None
 PSDI: None
 VDO: Tag name text field
 PSDO: None
 1. Tap to fill tag name text field contents
    a. Case in text field matches Tag name before tap
    a. Case in text field didn't match Tag name before tap
 */
extension AddTagPopupUITests: XCTestCase {
    
}
