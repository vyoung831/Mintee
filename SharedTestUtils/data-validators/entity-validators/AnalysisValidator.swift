//
//  AnalysisValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  ANL-1: An Analysis' analysisType can only be one of the following values:
//      * `Box`
//      * `Line`
//  (validated by getters)
//  ANL-9: An Analysis' rangeType can only be one of the following values:
//      * `Start/End`
//      * `Ranged`
//  (validated by getters)
//  ANL-5: An Analysis' order is either:
//      * `-1` OR
//      * A unique number greater than or equal to `0`
//  (validated by MOC_Validator)
//  ANL-6: An Analysis' name is unique. (validated by MOC_Validator)
//  ANL-7: An Analysis' legend is non-nil. (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class AnalysisValidator {
    
    static var validators: [(Analysis) -> ()] = [
        AnalysisValidator.validate_dateRange,
        AnalysisValidator.validate_startAndEndDates,
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
     ANL-11: If an Analysis' rangeType is `Ranged`, then its dateRange is greater than `0`..
     */
    static var validate_dateRange: (Analysis) -> () = { analysis in
        if analysis._rangeType == .dateRange {
            XCTAssert(analysis._dateRange > 0)
        }
    }
    
    /**
     ANL-12: If an Analysis' rangeType is `Start/End`, then its endDate is later than or equal to startDate.
     */
    static var validate_startAndEndDates: (Analysis) -> () = { analysis in
        if analysis._rangeType == .startEnd {
            XCTAssert(analysis._startDate!.lessThanOrEqualToDate(analysis._endDate!))
        }
    }
    
}

// MARK: - AnalysisLegend transformable validation

extension AnalysisValidator {
    
    static var validateLegend: (Analysis) -> () = { analysis in
        AnalysisLegendValidator.validateAnalysisLegend(analysis._legend)
    }
    
}
