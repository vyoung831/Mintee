//
//  BubbleRows-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils
@testable import Mintee

class BubbleRows_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.teardownTestContainer()
    }
    
    /**
     Test that BubbleRows respects the maxBubbleRadius provided
     */
    func test_getBubbleRadius_maxBubbleRadius_respected() {
        
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .none,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        let bubblesPerRow: Int = bubbleRows.bubbles[0].count
        let maxBubbleRadius: CGFloat = 30
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 and ensure that the calculated bubbleRadius isn't increased to fit the totalWdith
        let totalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * bubbleRows.minimumInterBubbleSpacing
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing + 1
        bubbleRows.maxBubbleRadius = maxBubbleRadius
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius == maxBubbleRadius)
    }
    
    /**
     Test that BubbleRows shrinks bubbles to respect the minimumInterBubblespacing
     */
    func test_getBubbleRadius_minimumInterBubbleSpacing_respected() {
        
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .none,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        let bubblesPerRow: Int = bubbleRows.bubbles[0].count
        let maxBubbleRadius: CGFloat = 30
        
        // Calculate the totalWidth needed with the minimumInterBubbleSpacing, then sub 1 and ensure that the calculated bubbleRadius is decreased to respect minimumInterBubbleSpacing
        let totalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * bubbleRows.minimumInterBubbleSpacing
        let totalWidth = (2 * maxBubbleRadius * CGFloat(bubblesPerRow)) + totalSpacing - 1
        bubbleRows.maxBubbleRadius = maxBubbleRadius
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        
        XCTAssert(radius < maxBubbleRadius)
    }
    
    func test_getGeometryReaderHeight() {
        let totalWidth: CGFloat = 200
        
        let bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .none,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        let rowCount = bubbleRows.bubbles.count
        
        // Given totalWidth and the default maxBubbleRadius, calculate the bubbleRadius and total GeometryReader height
        let radius = bubbleRows.getBubbleRadius(totalWidth: totalWidth)
        let grHeight = bubbleRows.getGeometryReaderHeight(totalWidth: totalWidth)
        
        let expectedHeight = ((2 * radius) * CGFloat(rowCount)) + (CGFloat(rowCount - 1) * bubbleRows.rowSpacing)
        XCTAssert(grHeight == expectedHeight)
    }
    
    /**
     Test that getHStackSpacing returns an increased HStack spacing (inter-bubble spacing) when the totalWidth is enough for bubbles to reach maxBubbleRadius
     */
    func test_getHstackSpacing_increasesHStackSpacing() {
        
        let bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .none,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        let bubblesPerRow = bubbleRows.bubbles[0].count
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 to overflow the width
        let minimumTotalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * bubbleRows.minimumInterBubbleSpacing
        let overflowWidth = (2 * bubbleRows.maxBubbleRadius * CGFloat(bubbleRows.bubbles[0].count)) + minimumTotalSpacing + 1
        let horizontalSpacing = bubbleRows.getHStackSpacing(totalWidth: overflowWidth)
        
        XCTAssert(bubbleRows.minimumInterBubbleSpacing < horizontalSpacing)
    }
    
    /**
     Test that getHStackSpacing returns minimumInterBubbleSpacing when totalWidth is not enough to accomodate the desired bubbleRadius
     */
    func test_getHStackSpacing_minimumInterBubbleSpacing_resistsCompression() {
        
        let bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .none,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        let bubblesPerRow = bubbleRows.bubbles[0].count
        
        // Calculate the totalWidth needed with the maxBubbleRadius, then add 1 to overflow the width
        let maxTotalSpacing: CGFloat = CGFloat(bubblesPerRow - 1) * bubbleRows.minimumInterBubbleSpacing
        let compressedWidth = (2 * bubbleRows.maxBubbleRadius * CGFloat(bubbleRows.bubbles[0].count)) + maxTotalSpacing - 1
        let horizontalSpacing = bubbleRows.getHStackSpacing(totalWidth: compressedWidth)
        
        XCTAssert(bubbleRows.minimumInterBubbleSpacing == horizontalSpacing)
    }
    
}

// MARK: - RowNeedsSpacers tests

extension BubbleRows_Tests {
    
    func test_rowNeedsSpacers_oneRow() {
        let bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
    }
    
    func test_rowNeedsSpacers_twoRows_firstRowMoreBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssert(bubbleRows.rowNeedsSpacers(1))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
    }
    
    func test_rowNeedsSpacers_twoRows_equalAmountOfBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
    }
    
    func test_rowNeedsSpacers_twoRows_secondRowMoreBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
    }
    
    func test_rowNeedsSpacers_threeRows_equalAmountOfBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(2))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(2))
    }
    
    func test_rowNeedsSpacers_threeRows_lastRowMostBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(2))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(2))
    }
    
    func test_rowNeedsSpacers_threeRows_lastRowLeastBubbles() {
        var bubbleRows = BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                             bubbles: [[.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                                                       [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]],
                                                             presentation: .centerLastRow,
                                                             toggleable: false,
                                                             selectedBubbles: .constant(Set<SaveFormatter.dayOfWeek>()))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssert(bubbleRows.rowNeedsSpacers(2))
        
        bubbleRows.presentation = .none
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(0))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(1))
        XCTAssertFalse(bubbleRows.rowNeedsSpacers(2))
    }
    
}
