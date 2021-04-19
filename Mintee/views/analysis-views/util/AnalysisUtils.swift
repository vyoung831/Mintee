//
//  AnalysisUtils.swift
//  Mintee
//
//  Created by Vincent Young on 4/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation

struct AnalysisUtils {
    
    enum dateRangeType: CaseIterable, SelectableType {
        
        case startEnd
        case dateRange
        
        var stringValue: String {
            switch self {
            case .startEnd: return "Start/End"
            case .dateRange: return "Ranged"
            }
        }
        
    }
    
}
