//
//  AnalysisLegendValidator.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 7/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class AnalysisLegendValidator {
    
    static var validators: [(AnalysisLegend) -> ()] = [
        AnalysisLegendValidator.validateLegendEntryCount,
        AnalysisLegendValidator.validate_categorizedLegendEntries,
        AnalysisLegendValidator.validate_completionLegendEntries
    ]
    
    public static func validateAnalysisLegend(_ analysisLegend: AnalysisLegend) {
        for validator in AnalysisLegendValidator.validators {
            validator(analysisLegend)
        }
    }
    
    /**
     ALGND-1: If an AnalysisLegend's categorizedEntries is non-empty, then its completionEntries is empty.
     ALGND-2: If an AnalysisLegend's completionEntries is non-empty, then its categorizedEntries is empty.
     */
    static var validateLegendEntryCount: (AnalysisLegend) -> () = { legend in
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
    
    /**
     CATLE-1: A CategorizedLegendEntry's category can only be one of the following values:
     - `Reached target`
     - `Under target`
     - `Over target`
     */
    static var validate_categorizedLegendEntries: (AnalysisLegend) -> () = { legend in
        if legend.categorizedEntries.count > 0 {
            for catle in legend.categorizedEntries {
                // CATLE-1
                XCTAssert(catle.category == .reachedTarget || catle.category == .underTarget || catle.category == .overTarget)
            }
        }
    }
    
}

// MARK: - CompletionLegendEntry validation

extension AnalysisLegendValidator {
    
    /**
     CMPLE-1: A CompletionLegendEntry's minOperator can only be one of the following values:
     - `Less than`
     - `Less than or equal to`
     - `Equal to`
     - `N/A`
     CMPLE-2: A CompletionLegendEntry's maxOperator can only be one of the following values:
     - `Less than`
     - `Less than or equal to`
     - `N/A`
     CMPLE-3: If a CompletionLegendEntry's maxOperator is `N/A`, then its max is `0`.
     CMPLE-4: If a CompletionLegendEntry's minOperator is `N/A`, then its min is `0`.
     CMPLE-5: A CompletionLegendEntry's minOperator and maxOperator cannot both be `N/A`.
     CMPLE-6: If a CompletionLegendEntry's minOperator is `Equal to`, then its maxOperator is `N/A`.
     CMPLE-7: If a CompletionLegendEntry's minOperator and maxOperator are both not `N/A`, then its min is less than its max.
     */
    static var validate_completionLegendEntries: (AnalysisLegend) -> () = { legend in
        
        if legend.completionEntries.count > 0 {
            
            for cmple in legend.completionEntries {
                
                // CMPLE-2
                XCTAssert(cmple.minOperator == .lt || cmple.minOperator == .lte || cmple.minOperator == .eq || cmple.minOperator == .na)
                
                // CMPLE-2
                XCTAssert(cmple.maxOperator == .lt || cmple.maxOperator == .lte || cmple.maxOperator == .na)
                
                // CMPLE-3
                if (cmple.maxOperator == .na) {
                    XCTAssert(cmple.max == 0)
                }
                
                // CMPLE-4
                if (cmple.minOperator == .na) {
                    XCTAssert(cmple.min == 0)
                }
                
                // CMPLE-5
                XCTAssertFalse( cmple.minOperator == .na && cmple.maxOperator == .na )
                
                // CMPLE-6
                if (cmple.minOperator == .eq ) {
                    XCTAssert( cmple.maxOperator == .na )
                }
                
                // CMPLE-7
                if (cmple.minOperator != .na && cmple.maxOperator != .na ) {
                    XCTAssert(cmple.min < cmple.max)
                }
                
            }
            
        }
        
    }
    
}
