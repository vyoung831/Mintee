//
//  AnalysisLegendValidator.swift
//  SharedTestUtils
//
//  Business rules NOT checked for by this validator:
//  * CATLE-1 (validated by getter)
//  * CMPLE-1 (validated by getter)
//  * CMPLE-2 (validated by getter)
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
     ALGND-1
     ALGND-2
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
     CMPLE-3
     CMPLE-4
     CMPLE-5
     CMPLE-6
     CMPLE-7
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
