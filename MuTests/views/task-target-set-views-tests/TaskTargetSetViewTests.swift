//
//  TaskTargetSetViewTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/1/1.
//  Copyright © 11 Vincent Young. All rights reserved.
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

    // MARK: - getLabel tests
    
    func testGetLabel_daysOfWeek() {
        let ttsv = TaskTargetSetView(type: .dow,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every week")
    }
    
    func testGetLabel_weekdaysOfMonth_singleWeek() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<String>(["4th"]))
        XCTAssert( ttsv.getLabel() == "4th of each month")
    }
    
    func testGetLabel_weekdaysOfMonth_multipleWeeks() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<String>(["Last","1st","3rd","2nd"]))
        XCTAssert( ttsv.getLabel() == "1st, 2nd, 3rd, Last of each month")
    }
    
    func testGetLabel_daysOfMonth() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every month")
    }
    
    // MARK: - getTarget tests
    
    func testGetTarget_minLessThan_maxLessThan() {
        var ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "1 < Target < 2" )
    }
    
    func testGetTarget_minLessThan_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "1 < Target <= 2" )
    }
    
    func testGetTarget_minLessThan_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }
    
    func testGetTarget_minLessThan_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target > 1" )
    }
    
    func testGetTarget_minLessThanEqual_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "1 <= Target < 2" )
    }
    
    func testGetTarget_minLessThanEqual_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "1 <= Target <= 2")
    }
    
    func testGetTarget_minLessThanEqual_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }
    
    func testGetTarget_minLessThanEqual_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target >= 1" )
    }
    
    func testGetTarget_minEqual_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func testGetTarget_minEqual_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func testGetTarget_minEqual_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func testGetTarget_minEqual_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func testGetTarget_minNotApplicable_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "Target < 2" )
    }
    
    func testGetTarget_minNotApplicable_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "Target <= 2" )
    }
    
    func testGetTarget_minNotApplicable_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }

}
