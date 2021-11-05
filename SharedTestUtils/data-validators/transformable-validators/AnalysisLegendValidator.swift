//
//  AnalysisLegendValidator.swift
//  SharedTestUtils
//
//  Business rules NOT checked for by this validator:
//  * CATLE-1
//  CMPLE-1: A CompletionLegendEntry's minOperator can only be one of the following values:
//      * `Less than`
//      * `Less than or equal to`
//      * `Equal to`
//      * `N/A`
//  (validated by getter)
//  CMPLE-2: A CompletionLegendEntry's maxOperator can only be one of the following values:
//      * `Less than`
//      * `Less than or equal to`
//      * `N/A`
//  (validated by getter)
//
//  Created by Vincent Young on 7/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class AnalysisLegendValidator {
    
    static var validators: [(AnalysisLegend) throws -> ()] = [
        AnalysisLegendValidator.validateLegendEntryCount,
        AnalysisLegendValidator.validate_categorizedLegendEntries,
        AnalysisLegendValidator.validate_completionLegendEntries
    ]
    
    public static func validateAnalysisLegend(_ analysisLegend: AnalysisLegend) {
        for validator in AnalysisLegendValidator.validators {
            try! validator(analysisLegend)
        }
    }
    
    /**
     ALGND-1: If an AnalysisLegend's categorizedEntries is non-empty, then its completionEntries is empty.
     ALGND-2: If an AnalysisLegend's completionEntries is non-empty, then its categorizedEntries is empty.
     */
    static var validateLegendEntryCount: (AnalysisLegend) throws -> () = { legend in
        if legend.categorizedEntries.count > 0 {
            XCTAssert(legend.completionEntries.count == 0) // ALGND-1
        } else if legend.completionEntries.count > 0 {
            XCTAssert(legend.categorizedEntries.count == 0) // ALGND-2
        } else {
            XCTFail()
        }
    }
    
}

// MARK: - CategorizedLegendEntry validation

extension AnalysisLegendValidator {
    
    static var validate_categorizedLegendEntries: (AnalysisLegend) throws -> () = { legend in }
    
}

// MARK: - CompletionLegendEntry validation

extension AnalysisLegendValidator {
    
    /**
     CMPLE-3: If a CompletionLegendEntry's maxOperator is `N/A`, then its max is `0`.
     CMPLE-4: If a CompletionLegendEntry's minOperator is `N/A`, then its min is `0`.
     CMPLE-5: A CompletionLegendEntry's minOperator and maxOperator cannot both be `N/A`.
     CMPLE-6: If a CompletionLegendEntry's minOperator is `Equal to`, then its maxOperator is `N/A`.
     CMPLE-7: If a CompletionLegendEntry's minOperator and maxOperator are both not `N/A`, then its min is less than its max.
     */
    static var validate_completionLegendEntries: (AnalysisLegend) throws -> () = { legend in
        
        for cmple in legend.completionEntries {
            
            let minOp = try cmple._minOperator
            let maxOp = try cmple._maxOperator
            
            // CMPLE-3
            if (maxOp == .na) {
                XCTAssert(cmple._max == 0)
            }
            
            // CMPLE-4
            if (minOp == .na) {
                XCTAssert(cmple._min == 0)
            }
            
            // CMPLE-5
            XCTAssertFalse( minOp == .na && maxOp == .na )
            
            // CMPLE-6
            if (minOp == .eq ) {
                XCTAssert( maxOp == .na )
            }
            
            // CMPLE-7
            if (minOp != .na && maxOp != .na ) {
                XCTAssert(cmple._min < cmple._max)
            }
            
        }
        
    }
    
}
