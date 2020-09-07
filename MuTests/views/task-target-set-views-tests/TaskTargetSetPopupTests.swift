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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Test checkOperators when min is less than max. ttsp is redeclared for each test case because SwiftUI doesn't support altering @State variables from external views
     */
    func testCheckOperatorsMinLessThanMax() throws {
        let min: Float = 3, max: Float = 4
        
        var ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
    }
    
    /**
     Test checkOperators when min is equal to max. ttsp is redeclared for each test case because SwiftUI doesn't support altering @State variables from external views
     */
    func testCheckOperatorsMinEqualToMax() throws {
        let min: Float = 4, max: Float = 4
        
        var ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
    }
    
    /**
     Test checkOperators when min is greater than max. ttsp is redeclared for each test case because SwiftUI doesn't support altering @State variables from external views
     */
    func testCheckOperatorsMinGreaterThanMax() throws {
        let min: Float = 5, max: Float = 4
        
        var ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lt, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .lte, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( !ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .eq, maxOperator: .na, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lt, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .lte, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        ttsp = TaskTargetSetPopup(title: "", minOperator: .na, maxOperator: .eq, isBeingPresented: self.$ibp, save: { ttsv in })
        XCTAssert( ttsp.checkOperators(min: min, max: max) )
        
    }

}
