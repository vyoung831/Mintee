//
//  TaskTargetSetViewTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/20/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class TaskTargetSetViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Test that getLabel returns the expected string when type is set to EqualityOperator.dow
     */
    func testGetLabelDaysOfWeek() {
        let ttsv = TaskTargetSetView(type: .dow,
                                     minTarget: 20,
                                     minOperator: .lt,
                                     maxTarget: 25,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every week")
    }
    
    /**
     Test that getLabel reorders the weeks of month and returns the expected string when type is set to EqualityOperator.wom
     */
    func testGetLabelWeekdaysOfMonth() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 20,
                                     minOperator: .lt,
                                     maxTarget: 25,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<String>(["1st","3rd","2nd"]))
        XCTAssert( ttsv.getLabel() == "1st, 2nd, 3rd of each month")
    }
    
    /**
     Test that getLabel returns the expected string when type is set to EqualityOperator.dom
     */
    func testGetLabelDaysOfMonth() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 20,
                                     minOperator: .lt,
                                     maxTarget: 25,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every month")
    }
    
    /**
     Test getTarget with TaskTargetSetView where one or both operators are set to EqualityOperator.lt
     */
    func testGetTargetLessThan() {
        
        // Min operator == .lt tests
        var ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 20,
                                     minOperator: .lt,
                                     maxTarget: 25,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "20 < Target < 25" )
        
        ttsv.maxOperator = .lte
        XCTAssert( ttsv.getTarget() == "20 < Target <= 25" )
        
        ttsv.maxOperator = .na
        XCTAssert( ttsv.getTarget() == "Target > 20" )
        
        // Max operator == .lt tests
        ttsv.maxOperator = .lt
        ttsv.minOperator = .na
        XCTAssert( ttsv.getTarget() == "Target < 25" )
        
    }
    
    /**
     Test getTarget with TaskTargetSetView where one or both operators are set to EqualityOperator.lte
     */
    func testGetTargetLessOrEqualTo() {
        
        // Min operator == .lte tests
        var ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 20,
                                     minOperator: .lte,
                                     maxTarget: 25,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "20 <= Target < 25" )
        
        ttsv.maxOperator = .lte
        XCTAssert( ttsv.getTarget() == "20 <= Target <= 25" )
        
        ttsv.maxOperator = .na
        XCTAssert( ttsv.getTarget() == "Target >= 20" )
        
        // Max operator = .lte tests
        ttsv.maxOperator = .lte
        ttsv.minOperator = .na
        XCTAssert( ttsv.getTarget() == "Target <= 25" )
        
    }
    
    /**
     Test getTarget when one of the operators is set to EqualityOperator.eq
     For each case, this test sets the other operator to .na because TaskTargetSetView only checks if operators are not .na when creating the label
     */
    func testGetTargetEqual() {
        
        var ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 20,
                                     minOperator: .eq,
                                     maxTarget: 25,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target = 20" )
        
        ttsv.minOperator = .na
        ttsv.maxOperator = .eq
        XCTAssert( ttsv.getTarget() == "Target = 25" )
        
    }
    
    

}
