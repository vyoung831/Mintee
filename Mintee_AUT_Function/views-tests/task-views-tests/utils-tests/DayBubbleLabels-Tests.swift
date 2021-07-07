//
//  DayBubbleLabels-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/10/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
@testable import SharedTestUtils
import XCTest

class DayBubbleLabels_Tests: XCTestCase {
    
    static let daysOfWeek: [String] = ["M","T","W","R","F","S","U"]
    static let weeksOfMonth: [String] = ["1st","2nd","3rd","4th","Last"]
    static let daysOfMonth: [String] = ["1","2","3","4","5","6","7","8","9",
                                        "10","11","12","13","14","15","16","17","18","19",
                                        "20","21","22","23","24","25","26","27","28","29",
                                        "30","31"]
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.teardownTestContainer()
    }

    func test_getDividedBubbleLabels_singleSubarray() throws {
        let dividedLabels = DayBubbleLabels.getDividedBubbles_daysOfWeek(bubblesPerRow: 7)
        XCTAssert(dividedLabels.count == 1)
        XCTAssert(dividedLabels[0] == [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
    }
    
    func test_getDividedBubbleLabels_multipleSubarray() throws {
        let dividedLabels = DayBubbleLabels.getDividedBubbles_daysOfWeek(bubblesPerRow: 3)
        XCTAssert(dividedLabels.count == 3)
        XCTAssert(dividedLabels[0] == [.monday, .tuesday, .wednesday])
        XCTAssert(dividedLabels[1] == [.thursday, .friday, .saturday])
        XCTAssert(dividedLabels[2] == [.sunday])
    }

}
