//
//  Date+Extensions.swift
//  Mu
//
//  Created by Vincent Young on 4/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Date {
    
    /**
     Returns a string representation of a Date for storing in Core Data
     */
    func toStoredString() -> String {
        let components = Calendar(identifier: .gregorian).dateComponents(in: .current, from: self)
        if let month = components.month, let day = components.day, let year = components.year {
            return (String(month) + "/" + String(day) + "/" + String(year))
        }
        return ""
    }
    
    /**
     Returns a String representation of a Date for presenting to user
     */
    func toMYD() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        return dateFormatterPrint.string(from: self)
    }
    
}
