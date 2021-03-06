//
//  TodayCollectionViewCell-Tests.swift
//  MuTests
//
//  Tests for TodayCollectionViewCell's completion meter functions.
//
//  Created by Vincent Young on 11/1/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest

class TodayCollectionViewCell_Tests: XCTestCase {
    
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}
    
    let negativeMinTarget: Float = -10
    let negativeMaxTarget: Float = -5
    let positiveMinTarget: Float = 5
    let positiveMaxTarget: Float = 10
    
}

// MARK: - getCompletionMeterPercentage tests.
/*
 Because TaskTargetSets can store targets as negative, zero, or positive, this class tests combinations of the following 2 combinations of variables:
 - Min and max operators (of type SaveFormatter.equalityOperator - lt, lte, eq, na). Note: because of TaskTargetSet's validation logic during instantiation, the following min/max operator combos (respectively) are not tested for:
    - lt/eq
    - lte/eq
    - eq/lt
    - eq/lte
    - eq/eq
    - na/eq
    - na/na
 - Min and max target values (negative, zero, positive)
 - Completion with combinations of the following traits:
    - Sign (positive/negative/equal to 0)
    - Relation to min and max target values (less than min, between 2 values, greater than max)
 
 Additionally, because the completion meter height doesn't differentiate between the equalityOperators (lt) and (lte), the following test scenario combos are replaced:
 - (lt)/(lte) combos are replaced with just the (lt)/(lt) combo
 - (lt/lte)/(na) combos are replaced with just the (lt)/(na) combo
 - (na)/(lt/lte) combos are replaced with just the (na)/(lt) combo
 */

// MARK: - getCompletionMeterPercentage tests with negative min target and negative max target

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_negative_negative() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -12) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -8) == 0.4 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -5) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -3) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 0) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 3) == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_na_negative_negative() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -8) == 0.8 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -5) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -3) == 0.3 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 3) == 0 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_negative_negative() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -8) == 0.8 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -5) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -3) == 0.3 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 3) == 0 )
    }
    
    func test_getCompletionMeterPercentage_na_lt_negative_negative() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -8) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -5) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: -3) == 0.6 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: negativeMaxTarget, completion: 3) == 0 )
    }
    
}

// MARK: - getCompletionMeterPercentage tests with negative min target and zero max target

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_negative_zero() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -12) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -8) == 0.2 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: 0) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: 3) == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_na_negative_zero() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -8) == 0.8 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: 3) == 0 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_negative_zero() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: -8) == 0.8 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: 0, completion: 3) == 0 )
    }
    
    func test_getCompletionMeterPercentage_na_lt_negative_zero() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: -8) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: 0) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: 0, completion: 3) == 1 )
    }
    
}

// MARK: - getCompletionMeterPercentage tests with negative min target and positive max target

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_negative_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -12) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -5) == 0.25 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0.65 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_na_negative_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -5) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 0 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_negative_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -12) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -5) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 0 )
    }
    
    func test_getCompletionMeterPercentage_na_lt_negative_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -12) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: -5) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0.3 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: negativeMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
}

// MARK: - getCompletionMeterPercentage tests with zero min target and positive max target

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_zero_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 7) == 0.7 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_na_zero_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 0) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 7) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_zero_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: -10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 0) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 7) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_na_lt_zero_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: -10) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 7) == 0.7 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
}

// MARK: - getCompletionMeterPercentage tests with positive min target and positive max target

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_positive_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: -7) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 5) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 8) == 0.6 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_na_positive_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: -7) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0.6 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 5) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 8) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_positive_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: -7) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0.6 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 5) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 8) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
    func test_getCompletionMeterPercentage_na_lt_positive_positive() {
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: -7) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 0) == 0 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 3) == 0.3 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 5) == 0.5 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 8) == 0.8 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 10) == 1 )
        XCTAssert(try! TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .lt, minTarget: positiveMinTarget, maxTarget: positiveMaxTarget, completion: 12) == 1 )
    }
    
}

// MARK: - getCompletionMeterColor tests (single equality operator)

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterColor_lt_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lt_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .yellow )
    }
    
    func test_getCompletionMeterColor_lt_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .green )
    }
    
    func test_getCompletionMeterColor_lte_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lte_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .green )
    }
    
    func test_getCompletionMeterColor_lte_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .green )
    }
    
    func test_getCompletionMeterColor_eq_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_eq_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .green )
    }
    
    func test_getCompletionMeterColor_eq_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .red )
    }
    
    func test_getCompletionMeterColor_na_lt_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 2) == .green )
    }
    
    func test_getCompletionMeterColor_na_lt_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 3) == .yellow )
    }
    
    func test_getCompletionMeterColor_na_lt_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 4) == .red )
    }
    
    func test_getCompletionMeterColor_na_lte_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 2) == .green )
    }
    
    func test_getCompletionMeterColor_na_lte_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_na_lte_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 4) == .red )
    }
    
    func test_getCompletionMeterColor_na_eq_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 2) == .red )
    }
    
    func test_getCompletionMeterColor_na_eq_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_na_eq_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 4) == .red )
    }
    
}

// MARK: - getCompletionMeterColor tests (2 equality operators)

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterColor_lt_lt_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lt_lt_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 0) == .yellow )
    }
    
    func test_getCompletionMeterColor_lt_lt_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_lt_lt_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 5) == .yellow )
    }
    
    func test_getCompletionMeterColor_lt_lt_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 6) == .red )
    }
    
    func test_getCompletionMeterColor_lt_lte_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lt_lte_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 0) == .yellow )
    }
    
    func test_getCompletionMeterColor_lt_lte_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_lt_lte_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 5) == .green )
    }
    
    func test_getCompletionMeterColor_lt_lte_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 6) == .red )
    }
    
    func test_getCompletionMeterColor_lte_lt_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lte_lt_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 0) == .green )
    }
    
    func test_getCompletionMeterColor_lte_lt_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_lte_lt_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 5) == .yellow )
    }
    
    func test_getCompletionMeterColor_lte_lt_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 6) == .red )
    }
    
    func test_getCompletionMeterColor_lte_lte_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: -1) == .red )
    }
    
    func test_getCompletionMeterColor_lte_lte_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 0) == .green )
    }
    
    func test_getCompletionMeterColor_lte_lte_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 3) == .green )
    }
    
    func test_getCompletionMeterColor_lte_lte_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 5) == .green )
    }
    
    func test_getCompletionMeterColor_lte_lte_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterColor(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 6) == .red )
    }
    
}


