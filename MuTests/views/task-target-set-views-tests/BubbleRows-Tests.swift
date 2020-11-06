//
//  BubbleRows-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class BubbleRows_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /**
     Test that BubbleRows respects the maxBubbleRadius provided
     */
    func test_getBubbleRadius_maxBubbleRadius_respected() {
        
        var bubbleRows = BubbleRows(bubbles: [["M","T","W","R","F","S","U"]],
                                    toggleable: false,
                                    selectedBubbles: .constant(Set<String>()))
        let bubblesPerRow: Int = bubbleRows.bubbles[0].count
        let maxBubbleRadius: CGFloat = 30
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 and ensure that the calculated bubbleRadius isn't increased to fit the totalWdith
        let totalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * BubbleRows.minimumInterBubbleSpacing
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing + 1
        bubbleRows.maxBubbleRadius = maxBubbleRadius
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius == maxBubbleRadius)
    }
    
    /**
     Test that BubbleRows shrinks bubbles to respect the minimumInterBubblespacing
     */
    func test_getBubbleRadius_minimumInterBubbleSpacing_respected() {
        
        var bubbleRows = BubbleRows(bubbles: [["M","T","W","R","F","S","U"]],
                                    toggleable: false,
                                    selectedBubbles: .constant(Set<String>()))
        let bubblesPerRow: Int = bubbleRows.bubbles[0].count
        let maxBubbleRadius: CGFloat = 30
        
        // Calculate the totalWidth needed with the minimumInterBubbleSpacing, then sub 1 and ensure that the calculated bubbleRadius is decreased to respect minimumInterBubbleSpacing
        let totalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * BubbleRows.minimumInterBubbleSpacing
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing - 1
        bubbleRows.maxBubbleRadius = maxBubbleRadius
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius < maxBubbleRadius)
    }
    
    func test_getGeometryReaderHeight() {
        let totalWidth: CGFloat = 200
        
        var bubbleRows = BubbleRows(bubbles: [["M","T","W","R","F","S","U"]],
                                    toggleable: false,
                                    selectedBubbles: .constant(Set<String>()))
        let rowCount = bubbleRows.bubbles.count
        
        // Given totalWidth and the default maxBubbleRadius, calculate the bubbleRadius and total GeometryReader height
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        let grHeight = bubbleRows.getGeometryReaderHeight(totalWidth: totalWidth)
        
        let expectedHeight = ((2 * radius) * CGFloat(rowCount)) + (CGFloat(rowCount - 1) * BubbleRows.rowSpacing)
        XCTAssert(grHeight == expectedHeight)
    }
    
    /**
     Test that getHStackSpacing returns an increased HStack spacing (inter-bubble spacing) when the totalWidth is enough for bubbles to reach maxBubbleRadius
     */
    func test_getHstackSpacing_increasesHStackSpacing() {
        
        var bubbleRows = BubbleRows(bubbles: [["M","T","W","R","F","S","U"]],
                                    toggleable: false,
                                    selectedBubbles: .constant(Set<String>()))
        let bubblesPerRow = bubbleRows.bubbles[0].count
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 to overflow the width
        let minimumTotalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * BubbleRows.minimumInterBubbleSpacing
        let overflowWidth = (2 * bubbleRows.maxBubbleRadius * CGFloat(bubbleRows.bubbles[0].count)) + minimumTotalSpacing + 1
        let horizontalSpacing = bubbleRows.getHStackSpacing(totalWidth: overflowWidth)
        
        XCTAssert(BubbleRows.minimumInterBubbleSpacing < horizontalSpacing)
    }
    
    /**
     Test that getHStackSpacing returns minimumInterBubbleSpacing when totalWidth is not enough to accomodate the desired bubbleRadius
     */
    func test_getHStackSpacing_minimumInterBubbleSpacing_resistsCompression() {
        
        var bubbleRows = BubbleRows(bubbles: [["M","T","W","R","F","S","U"]],
                                    toggleable: false,
                                    selectedBubbles: .constant(Set<String>()))
        let bubblesPerRow = bubbleRows.bubbles[0].count
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 to overflow the width
        let maxTotalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * BubbleRows.minimumInterBubbleSpacing
        let compressedWidth = (2 * bubbleRows.maxBubbleRadius * CGFloat(bubbleRows.bubbles[0].count)) + maxTotalSpacing - 1
        let horizontalSpacing = bubbleRows.getHStackSpacing(totalWidth: compressedWidth)
        
        XCTAssert(BubbleRows.minimumInterBubbleSpacing == horizontalSpacing)
    }
    
}
