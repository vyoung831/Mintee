//
//  BubbleRowsTestCase.swift
//  MuTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class BubbleRowsTestCase: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Test that BubbleRows respects the maxBubbleRadius provided
     */
    func testMaxBubbleRadius() {
        let totalSpacing: CGFloat = 6 * BubbleRows.minimumInterBubbleSpacing
        let maxBubbleRadius: CGFloat = 30
        let bubblesPerRow: Int = 7
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing + 1
        
        let br = BubbleRows(bubblesPerRow: bubblesPerRow, maxBubbleRadius: maxBubbleRadius, bubbles: [[]], selectedBubbles: Set([]))
        let radius = br.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius == maxBubbleRadius)
    }
    
    /**
     Test that BubbleRows shrinks bubbles to respect the minimumInterBubblespacing
     */
    func testSmallerBubbleRadius() {
        let totalSpacing: CGFloat = 6 * BubbleRows.minimumInterBubbleSpacing
        let maxBubbleRadius: CGFloat = 30
        let bubblesPerRow: Int = 7
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing - 1
        
        let br = BubbleRows(bubblesPerRow: bubblesPerRow, maxBubbleRadius: maxBubbleRadius, bubbles: [[]], selectedBubbles: Set([]))
        let radius = br.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius < maxBubbleRadius)
    }

}
