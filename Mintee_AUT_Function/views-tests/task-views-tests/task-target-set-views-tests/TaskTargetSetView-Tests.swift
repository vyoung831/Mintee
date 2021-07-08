//
//  TaskTargetSetView-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/1/1.
//  Copyright © 11 Vincent Young. All rights reserved.
//

import XCTest
@testable import SharedTestUtils
@testable import Mintee

class TaskTargetSetView_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
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
                                     selectedWeeksOfMonth: Set<SaveFormatter.weekOfMonth>([.fourth]))
        XCTAssert( ttsv.getLabel() == "4th of each month")
    }
    
    func test_getLabel_weekdaysOfMonth_multipleWeeks() {
        let ttsv = TaskTargetSetView(type: .wom,
                                     minTarget: 1,
                                     minOperator: .lt,
                                     maxTarget: 2,
                                     maxOperator: .lt,
                                     selectedWeeksOfMonth: Set<SaveFormatter.weekOfMonth>([.last, .first, .third, .second]))
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
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lt,
                                                     maxOperator: .lt,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "1 < Target < 2" )
    }
    
    func test_getTarget_minLessThan_maxLessThanEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lt,
                                                     maxOperator: .lte,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "1 < Target <= 2" )
    }
    
    func test_getTarget_minLessThan_maxEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lt,
                                                     maxOperator: .eq,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 2" )
    }
    
    func test_getTarget_minLessThan_maxNotApplicable() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lt,
                                                     maxOperator: .na,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target > 1" )
    }
    
    func test_getTarget_minLessThanEqual_maxLessThan() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lte,
                                                     maxOperator: .lt,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "1 <= Target < 2" )
    }
    
    func test_getTarget_minLessThanEqual_maxLessThanEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lte,
                                                     maxOperator: .lte,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "1 <= Target <= 2")
    }
    
    func test_getTarget_minLessThanEqual_maxEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lte,
                                                     maxOperator: .eq,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 2" )
    }
    
    func test_getTarget_minLessThanEqual_maxNotApplicable() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .lte,
                                                     maxOperator: .na,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target >= 1" )
    }
    
    func test_getTarget_minEqual_maxLessThan() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .eq,
                                                     maxOperator: .lt,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxLessThanEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .eq,
                                                     maxOperator: .lte,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .eq,
                                                     maxOperator: .eq,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 1" )
    }
    
    func test_getTarget_minEqual_maxNotApplicable() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .eq,
                                                     maxOperator: .na,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 1" )
    }
    
    func test_getTarget_minNotApplicable_maxLessThan() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .na,
                                                     maxOperator: .lt,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target < 2" )
    }
    
    func test_getTarget_minNotApplicable_maxLessThanEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .na,
                                                     maxOperator: .lte,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target <= 2" )
    }
    
    func test_getTarget_minNotApplicable_maxEqual() {
        XCTAssert( TaskTargetSetView.getTargetString(minOperator: .na,
                                                     maxOperator: .eq,
                                                     minTarget: 1,
                                                     maxTarget: 2)
                    == "Target = 2" )
    }
    
}
