//
//  TaskTargetSetPopup-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import XCTest
@testable import SharedTestUtils
@testable import Mintee

class TaskTargetSetPopup_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.rollbackTestContainer()
    }
    
    // MARK: - Insufficient input tests
    
    func test_checkEmptyValues_insufficientInput() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssert(ttsp.checkEmptyValues())
    }
    
    func test_checkEmptyValues_insufficientInput_minValueOnly() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    func test_checkEmptyValues_insufficientInput_maxValueOnly() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    func test_checkEmptyValues_insufficientInput_minAndMaxValues() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0", maxValueString: "0", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    // MARK: - Input validation tests
    
    func test_validateMinValue_validInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0.3", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssert(ttsp.validateMinValue() != nil)
    }
    
    func test_validateMinValue_invalidInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0.3d", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssert(ttsp.validateMinValue() == nil)
    }
    
    func test_validateMaxValue_validInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0.3", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssert(ttsp.validateMaxValue() != nil)
    }
    
    func test_validateMaxValue_invalidInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0.3d", isBeingPresented: .constant(true), save: { ttsv in })
        XCTAssert(ttsp.validateMaxValue() == nil)
    }
    
}
