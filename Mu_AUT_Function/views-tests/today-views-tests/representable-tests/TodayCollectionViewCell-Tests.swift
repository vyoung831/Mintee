//
//  TodayCollectionViewCell-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 11/1/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest

class TodayCollectionViewCell_Tests: XCTestCase {
    
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}
    
}

// MARK: - getCompletionMeterPercentage tests

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterPercentage_lt_lt_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_lt_lt_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 1.5)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_lt_lt_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 3)
                    == 1 )
    }
    
    func test_getCompletionMeterPercentage_lt_lte_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_lt_lte_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 1.5)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_lt_lte_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 3)
                    == 1 )
    }
    
    func test_getCompletionMeterPercentage_lte_lt_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_lte_lt_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 1.5)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_lte_lt_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 3)
                    == 1 )
    }
    
    func test_getCompletionMeterPercentage_lte_lte_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_lte_lte_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 1.5)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_lte_lte_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 3)
                    == 1 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 2, maxTarget: 0, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 2, maxTarget: 0, completion: 1)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_eq_na_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .eq, maxOp: .na, minTarget: 2, maxTarget: 0, completion: 2)
                    == 1 )
    }
    
    func test_getCompletionMeterPercentage_na_eq_empty() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 2, completion: 0)
                    == 0 )
    }
    
    func test_getCompletionMeterPercentage_na_eq_partial() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 2, completion: 1)
                    == 0.5 )
    }
    
    func test_getCompletionMeterPercentage_na_eq_full() {
        XCTAssert(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 2, completion: 2)
                    == 1 )
    }
    
}

// MARK: - getCompletionMeterColor tests

extension TodayCollectionViewCell_Tests {
    
    func test_getCompletionMeterColor_lt_lt_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lt_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 0) == .borderline )
    }
    
    func test_getCompletionMeterColor_lt_lt_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lt_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 5) == .borderline )
    }
    
    func test_getCompletionMeterColor_lt_lt_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 6) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lte_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lte_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 0) == .borderline )
    }
    
    func test_getCompletionMeterColor_lt_lte_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lte_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 5) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lt_lte_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 6) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lt_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lt_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 0) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lt_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lt_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 5) == .borderline )
    }
    
    func test_getCompletionMeterColor_lte_lt_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lt, minTarget: 0, maxTarget: 5, completion: 6) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lte_lessThanMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lte_equalToMin() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 0) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lte_inBetween() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lte_equalToMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 5) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_lte_greaterThanMax() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .lte, minTarget: 0, maxTarget: 5, completion: 6) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lt_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lt_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .borderline )
    }
    
    func test_getCompletionMeterColor_lt_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lt, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_lte_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_lte_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .lte, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_na_lt_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 2) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_na_lt_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 3) == .borderline )
    }
    
    func test_getCompletionMeterColor_na_lt_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lt, minTarget: 0, maxTarget: 3, completion: 4) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_na_lte_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 2) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_na_lte_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_na_lte_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .lte, minTarget: 0, maxTarget: 3, completion: 4) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_eq_na_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: -1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_eq_na_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 0) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_eq_na_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .eq, maxOp: .na, minTarget: 0, maxTarget: 0, completion: 1) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_na_eq_lessThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 2) == .unsatisfactory )
    }
    
    func test_getCompletionMeterColor_na_eq_equalTo() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 3) == .satisfactory )
    }
    
    func test_getCompletionMeterColor_na_eq_greaterThan() {
        XCTAssert( TodayCollectionViewCell.getCompletionMeterStatus(minOp: .na, maxOp: .eq, minTarget: 0, maxTarget: 3, completion: 4) == .unsatisfactory )
    }
    
}
