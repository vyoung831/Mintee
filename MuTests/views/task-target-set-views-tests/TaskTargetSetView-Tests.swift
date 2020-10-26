//
//  TaskTargetSetView-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 6/1/1.
//  Copyright © 11 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class TaskTargetSetView_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - getLabel tests
    
    func test_getLabel_daysOfWeek() {
        let ttsv = TaskTargetSetView(type: .dow,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every week")
    }
    
    func test_getLabel_weekdaysOfMonth_singleWeek() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<String>(["4th"]))
        XCTAssert( ttsv.getLabel() == "4th of each month")
    }
    
    func test_getLabel_weekdaysOfMonth_multipleWeeks() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<String>(["Last","1st","3rd","2nd"]))
        XCTAssert( ttsv.getLabel() == "1st, 2nd, 3rd, Last of each month")
    }
    
    func test_getLabel_daysOfMonth() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getLabel() == "Every month")
    }
    
    // MARK: - getTarget tests
    
    func test_getTarget_minLessThan_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "1 < Target < 2" )
    }
    
    func test_getTarget_minLessThan_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "1 < Target <= 2" )
    }
    
    func test_getTarget_minLessThan_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }
    
    func test_getTarget_minLessThan_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target > 1" )
    }
    
    func test_getTarget_minLessThanEqual_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "1 <= Target < 2" )
    }
    
    func test_getTarget_minLessThanEqual_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "1 <= Target <= 2")
    }
    
    func test_getTarget_minLessThanEqual_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }
    
    func test_getTarget_minLessThanEqual_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .lte,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target >= 1" )
    }
    
    func test_getTarget_minEqual_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxNotApplicable() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .eq,
                                     maxTarget: 2,
                                     maxOperator: .na)
        XCTAssert( ttsv.getTarget() == "Target = 1" )
    }
    
    func test_getTarget_minNotApplicable_maxLessThan() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .lt)
        XCTAssert( ttsv.getTarget() == "Target < 2" )
    }
    
    func test_getTarget_minNotApplicable_maxLessThanEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .lte)
        XCTAssert( ttsv.getTarget() == "Target <= 2" )
    }
    
    func test_getTarget_minNotApplicable_maxEqual() {
        let ttsv = TaskTargetSetView(type: .dom,
                                     minTarget: 1,
                                     minOperator: .na,
                                     maxTarget: 2,
                                     maxOperator: .eq)
        XCTAssert( ttsv.getTarget() == "Target = 2" )
    }

}
