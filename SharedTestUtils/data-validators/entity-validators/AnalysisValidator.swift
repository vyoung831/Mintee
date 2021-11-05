//
//  AnalysisValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  ANL-1 (validated by getters)
//  ANL-9 (validated by getters)
//  ANL-5 (validated by MOC_Validator)
//  ANL-6 (validated by MOC_Validator)
//  ANL-7 (defined as non-optional in NSManagedObject subclass)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class AnalysisValidator {
    
    static var validators: [(Analysis) throws -> ()] = [
        AnalysisValidator.validate_dateRange,
        AnalysisValidator.validate_startAndEndDates,
        AnalysisValidator.validateLegend
    ]
    
    static func validateAnalyses(_ analyses: Set<Analysis>) {
        for analysis in analyses {
            for validator in AnalysisValidator.validators {
                try! validator(analysis)
            }
        }
    }
    
    /**
     ANL-11
     */
    static var validate_dateRange: (Analysis) throws -> () = { analysis in
        if try analysis._rangeType == .dateRange {
            XCTAssert(try analysis._dateRange > 0)
        }
    }
    
    /**
     ANL-12
     */
    static var validate_startAndEndDates: (Analysis) throws -> () = { analysis in
        if try analysis._rangeType == .startEnd {
            XCTAssert((try analysis._startDate!).lessThanOrEqualToDate(try analysis._endDate!))
        }
    }
    
}

// MARK: - AnalysisLegend transformable validation

extension AnalysisValidator {
    
    static var validateLegend: (Analysis) throws -> () = { analysis in
        AnalysisLegendValidator.validateAnalysisLegend(analysis._legend)
    }
    
}
