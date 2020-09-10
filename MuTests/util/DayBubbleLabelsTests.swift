//
//  DayBubbleLabelsTests.swift
//  MuTests
//
//  Created by Vincent Young on 9/10/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest

class DayBubbleLabelsTests: XCTestCase {
    
    static let daysOfWeek: [String] = ["M","T","W","R","F","S","U"]
    static let weeksOfMonth: [String] = ["1st","2nd","3rd","4th","Last"]
    static let daysOfMonth: [String] = ["1","2","3","4","5","6","7","8","9",
                                        "10","11","12","13","14","15","16","17","18","19",
                                        "20","21","22","23","24","25","26","27","28","29",
                                        "30","31"]
    
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testGetDividedBubbleLabels_singleSubarray() throws {
        let dividedLabels = DayBubbleLabels.getDividedBubbleLabels(bubblesPerRow: 7, patternType: .dow)
        XCTAssert(dividedLabels.count == 1)
        XCTAssert(dividedLabels[0] == ["M","T","W","R","F","S","U"])
    }
    
    func testGetDividedBubbleLabels_multipleSubarray() throws {
        let dividedLabels = DayBubbleLabels.getDividedBubbleLabels(bubblesPerRow: 3, patternType: .dow)
        XCTAssert(dividedLabels.count == 3)
        XCTAssert(dividedLabels[0] == ["M","T","W"])
        XCTAssert(dividedLabels[1] == ["R","F","S"])
        XCTAssert(dividedLabels[2] == ["U"])
    }

}
