//
//  AnalysisValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  ANL-5: An Analysis' order must be either
//      * -1 OR
//      * A unique number greater than or equal to 0
//  (validated by MOC_Validator)
//  ANL-6: An Analysis' name must be unique. (constrained by XC data model)
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
        AnalysisValidator.validateAnalysisDateValues
    ]
    
    static func validateAnalyses(_ analyses: Set<Analysis>) {
        for analysis in analyses {
            for validator in AnalysisValidator.validators {
                validator(analysis)
            }
        }
    }
    
    /**
     ANL-1: An Analysis' analysisType can only be one of the following values
     - Box
     - Line
     */
    static var validateAnalysisType: (Analysis) -> () = { analysis in
        XCTAssert(analysis._analysisType == 0 || analysis._analysisType == 1)
    }
    
    /**
     ANL-2: An Analysis' startDate and endDate must
        - both be non-nil, OR
        - both be nil
     ANL-3: If an Analysis' startDate and endDate are both non-nil, its dateRange must be 0.
     ANL-4: If an Analysis' startDate and endDate are both nil, its dateRange must be greater than 0.
     */
    static var validateAnalysisDateValues: (Analysis) -> () = { analysis in
        // ANL-2
        if analysis._startDate == nil && analysis._endDate == nil {
            XCTAssert(analysis._dateRange > 0) // ANL-4
        } else if analysis._startDate != nil && analysis._endDate != nil {
            XCTAssert(analysis._dateRange == 0) // ANL-3
        }
        XCTFail()
    }
    
}
