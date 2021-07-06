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
        AnalysisLegendValidator.validateLegendEntryCount
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
        
        if legend.categorizedEntries.count == 0 {
            XCTAssert(legend.completionEntries.count > 0)
        } else if legend.completionEntries.count == 0 {
            XCTAssert(legend.categorizedEntries.count > 0)
        } else {
            XCTFail()
        }
        
    }
    
}
