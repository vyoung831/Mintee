//
//  TaskTargetSetPopupTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import XCTest
@testable import Mu

class TaskTargetSetPopupTests: XCTestCase {
    
    @State var ibp: Bool = true
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    // MARK: - Insufficient input tests
    
    func testDone_insufficientInput() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert(ttsp.checkEmptyValues())
    }
    
    func testDone_insufficientInput_minValueOnly() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    func testDone_insufficientInput_maxValueOnly() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    func testDone_insufficientInput_minAndMaxValues() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0", maxValueString: "0", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse(ttsp.checkEmptyValues())
    }
    
    // MARK: - Input validation tests
    
    func testValidateMinValue_validInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0.3", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert(ttsp.validateMinValue() != nil)
    }
    
    func testValidateMinValue_invalidInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, minValueString: "0.3d", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert(ttsp.validateMinValue() == nil)
    }
    
    func testValidateMaxValue_validInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0.3", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert(ttsp.validateMaxValue() != nil)
    }
    
    func testValidateMaxValue_invalidInput() {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, maxValueString: "0.3d", isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert(ttsp.validateMaxValue() == nil)
    }
    
}

// MARK: - checkOperators tests where min < max

extension TaskTargetSetPopupTests {
    
    func testCheckOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
    func testCheckOperators_minLessThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 3, max: 4) )
    }
    
}

// MARK: - checkOperators tests where min = max

extension TaskTargetSetPopupTests {
    
    func testCheckOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThan_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
    func testCheckOperators_minEqualToMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 4, max: 4) )
    }
    
}

// MARK: - checkOperators tests where min > max

extension TaskTargetSetPopupTests {
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThan_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorLessThanEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorEqual_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorEqual_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssertFalse( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorEqual_maxOperatorNotApplicable() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThan() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorLessThanEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
    func testCheckOperators_minGreaterThanMax_minOperatorNotApplicable_maxOperatorEqual() throws {
        let ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: 5, max: 4) )
    }
    
}
