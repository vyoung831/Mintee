//
//  Extensions.swift
//  MuTests
//
//  Created by Vincent Young on 8/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Date to String conversion
    
    static let ymdFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    static func toYMDTest(_ date: Date) -> String {
        return ymdFormatter.string(from: date)
    }
    
}
