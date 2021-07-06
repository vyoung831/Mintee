//
//  AnalysisListUITests.swift
//  Mintee_UIT
//
//  UI elements that are NOT tested
//  - Cancel button
//
//  Created by Vincent Young on 5/9/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils

class AnalysisListUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        MOC_Validator.validate()
    }

}

// MARK: - Save button tests

/*
 VDI:
    1. Order of Analysis cards
 PCDI: None
 VDO: None (Analysis page views are counted as PCDO)
 PCDO:
    1. Analyses' orders
 Combinations:
 VDI1
    - AnalysisListCard dragging tests
    - AnalysisListCard checkbox tests
 */
extension AnalysisListUITests {}

// MARK: - AnalysisListCard tests

/*
 Dragging tests
 VDI:
    1. Order of Analysis cards
 PCDI: None
 VDO:
    1. Order of Analysis cards
 PCDO: None
 Combinations (assuming (>2) unincluded and (>2) included cards):
 VDI1
    - Drag top included card to middle
    - Drag middle included card to top
    - Drag middle included card to bottom
    - Drag bottom included card to middle
    - Drag top included card to bottom
    - Drag bottom included card to top
    - Drag unincluded card to top
    - Drag top included card to bottom of unincluded cards
 */
extension AnalysisListUITests {}

/*
 Checkbox tests
 VDI:
    1. `Include on Homepage` checkboxes of Analysis cards
 PCDI: None
 VDO:
    1. Order of Analysis cards
    2. Checkboxes of Analysis cards
 PCDO: None
 Combinations (assuming (>2) unincluded and (>2) included cards):
 VDI1
    - Check first unincluded card
    - Check middle unincluded card
    - Check last unincluded card
    - Un-check first included card
    - Un-check middle included card
    - Un-check last included card
 */
extension AnalysisListUITests {}

// MARK: - Integration with EditAnalysis

extension AnalysisListUITests {}
