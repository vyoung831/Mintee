//
//  AnalysisValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  ANL-5: An Analysis' order is either:
//      * `-1` OR
//      * A unique number greater than or equal to `0`
//  (validated by MOC_Validator)
//  ANL-6: An Analysis' name is unique. (validated by MOC_Validator)
//  ANL-7: An Analysis' legend is non-nil. (validated as part of calling AnalysisLegendValidator)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class AnalysisValidator {
    
    static var validators: [(Analysis) -> ()] = [
        AnalysisValidator.validateAnalysisType,
        AnalysisValidator.validateAnalysisDateValues,
        AnalysisValidator.validateLegend
    ]
    
    static func validateAnalyses(_ analyses: Set<Analysis>) {
        for analysis in analyses {
            for validator in AnalysisValidator.validators {
                validator(analysis)
            }
        }
    }
    
    /**
     ANL-1: An Analysis' analysisType can only be one of the following values:
     - `Box`
     - `Line`
     */
    static var validateAnalysisType: (Analysis) -> () = { analysis in
        XCTAssert(analysis._analysisType == 0 || analysis._analysisType == 1)
    }
    
    /**
     ANL-2: An Analysis' startDate and endDate are either:
     - both non-nil OR
     - both nil
     ANL-3: If an Analysis' startDate and endDate are both non-nil, then its dateRange is `0`.
     ANL-4: If an Analysis' startDate and endDate are both nil, then its dateRange is greater than `0`.
     ANL-8: If an Analysis' startDate and endDate are both non-nil, then its endDate is later than or equal to startDate.
     */
    static var validateAnalysisDateValues: (Analysis) -> () = { analysis in
        // ANL-2
        if analysis._startDate == nil && analysis._endDate == nil {
            XCTAssert(analysis._dateRange > 0) // ANL-4
        } else if analysis._startDate != nil && analysis._endDate != nil {
            XCTAssert(analysis._dateRange == 0) // ANL-3
            XCTAssert(SaveFormatter.storedStringToDate(analysis._startDate!)!.lessThanOrEqualToDate(SaveFormatter.storedStringToDate(analysis._endDate!)!)) // ANL-8
        }
        XCTFail()
    }
    
}

// MARK: - AnalysisLegend transformable validation

extension AnalysisValidator {
    
    static var validateLegend: (Analysis) -> () = { analysis in
        AnalysisLegendValidator.validateAnalysisLegend(analysis._legend!)
    }
    
}
