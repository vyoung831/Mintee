//
//  BubbleRowsTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class BubbleRowsTests: XCTestCase {

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
        let bubbles = [["0","1","2","3","4","5","6"]]
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubbles[0].count)) + totalSpacing + 1
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let radius = br.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius == maxBubbleRadius)
    }
    
    /**
     Test that BubbleRows shrinks bubbles to respect the minimumInterBubblespacing
     */
    func testSmallerBubbleRadius() {
        let totalSpacing: CGFloat = 6 * BubbleRows.minimumInterBubbleSpacing
        let maxBubbleRadius: CGFloat = 30
        let bubbles = [["0","1","2","3","4","5","6"]]
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubbles[0].count)) + totalSpacing - 1
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let radius = br.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius < maxBubbleRadius)
    }
    
    /**
     Test the getBubbleRadius and getGeometryReaderHeight functions when empty rows of bubbles are provided to BubbleRows
     */
    func testGeometryReaderHeightEmpty() {
        let maxBubbleRadius: CGFloat = 8
        let totalWidth: CGFloat = 200
        let bubbles: [[String]] = [[],[],[]]
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let grHeight = br.getGeometryReaderHeight(totalWidth: totalWidth)
        
        XCTAssert(grHeight == 0)
    }
    
    /**
     Test the getBubbleRadius and getGeometryReaderHeight functions
     */
    func testGeometryReaderHeight() {
        let maxBubbleRadius: CGFloat = 8
        let totalWidth: CGFloat = 200
        let bubbles = [["1","2","3","4","5","6","7"],
                       ["8","9","10","11","12","13","14"]]
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let radius = br.getBubbleRadius(totalWidth: totalWidth)
        let grHeight = br.getGeometryReaderHeight(totalWidth: totalWidth)
        
        let expectedHeight = ((2 * radius) * CGFloat(bubbles.count)) + (CGFloat(bubbles.count - 1) * BubbleRows.rowSpacing)
        XCTAssert(grHeight == expectedHeight)
    }
    
    /**
     Test that BubbleRows increase HStack spacing when totalWidth is wide enough for bubbles to reach maxBubbleRadius
     */
    func testIncreasedHStackSpacing() {
        let totalSpacing: CGFloat = 6 * BubbleRows.minimumInterBubbleSpacing
        let maxBubbleRadius: CGFloat = 30
        let bubbles = [["0","1","2","3","4","5","6"]]
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubbles[0].count)) + totalSpacing + 1
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let horizontalSpacing = br.getHStackSpacing(totalWidth: totalWidth)
        
        XCTAssert(BubbleRows.minimumInterBubbleSpacing < horizontalSpacing)
    }
    
    /**
     Test that BubbleRows returns minimumInterBubbleSpacing when totalWidth is not enough
     */
    func testHStackSpacingCompressionResistance() {
        let totalWidth: CGFloat = 6 * BubbleRows.minimumInterBubbleSpacing
        let maxBubbleRadius: CGFloat = 30
        let bubbles = [["0","1","2","3","4","5","6"]]
        
        let br = BubbleRows(maxBubbleRadius: maxBubbleRadius,
                            bubbles: bubbles,
                            selectedBubbles: Set([]))
        let horizontalSpacing = br.getHStackSpacing(totalWidth: totalWidth)
        
        XCTAssert(BubbleRows.minimumInterBubbleSpacing == horizontalSpacing)
    }

}
