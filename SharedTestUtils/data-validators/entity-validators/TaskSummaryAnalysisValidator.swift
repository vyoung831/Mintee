//
//  TaskSummaryAnalysisValidator.swift
//  Mintee_AUT_Function
//
//  TSA-7: An TaskSummaryAnalysis' legend is non-nil. (validated as part of calling AnalysisLegendValidator)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TaskSummaryAnalysisValidator {
    
    static var validators: [(TaskSummaryAnalysis) -> ()] = [
        TaskSummaryAnalysisValidator.validateAnalysisType,
        TaskSummaryAnalysisValidator.validateAnalysisDateValues,
        TaskSummaryAnalysisValidator.validateTaskAssociation,
        TaskSummaryAnalysisValidator.validateLegend
    ]
    
    static func validateAnalyses(_ analyses: Set<TaskSummaryAnalysis>) {
        for analysis in analyses {
            for validator in TaskSummaryAnalysisValidator.validators {
                validator(analysis)
            }
        }
    }
    
    /**
     TSA-1: A TaskSummaryAnalysis' analysisType can only be one of the following values:
     - `Box`
     - `Line`
     */
    static var validateAnalysisType: (TaskSummaryAnalysis) -> () = { tsa in
        XCTAssert(tsa._analysisType == 0 || tsa._analysisType == 1)
    }
    
    /**
     TSA-2: A TaskSummaryAnalysis' startDate and endDate are either:
        - both non-nil OR
        - both nil
     TSA-3: If a TaskSummaryAnalysis' startDate and endDate are both non-nil, then its dateRange is `0`.
     TSA-4: If a TaskSummaryAnalysis' startDate and endDate are both nil, then its dateRange is greater than `0`.
     */
    static var validateAnalysisDateValues: (TaskSummaryAnalysis) -> () = { tsa in
        // TSA-2
        if tsa._startDate == nil && tsa._endDate == nil {
            XCTAssert(tsa._dateRange > 0) // TSA-4
        } else if tsa._startDate != nil && tsa._endDate != nil {
            XCTAssert(tsa._dateRange == 0) // TSA-3
        }
        XCTFail()
    }
    
    /**
     TSA-5: A TaskSummaryAnalysis is associated with one and only one Task.
     */
    static var validateTaskAssociation: (TaskSummaryAnalysis) -> () = { tsa in
        XCTAssert(tsa._task != nil)
    }
    
}

// MARK: - AnalysisLegend transformable validation

extension TaskSummaryAnalysisValidator {
    
    static var validateLegend: (TaskSummaryAnalysis) -> () = { tsa in
        AnalysisLegendValidator.validateAnalysisLegend(tsa._legend!)
    }
    
}

