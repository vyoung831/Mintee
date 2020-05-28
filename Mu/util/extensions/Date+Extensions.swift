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
     Returns a "MMM dd,yyyy" String representation of a Date for presenting to user
     */
    func toMYD() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.string(from: self)
    }
    
    /**
     Using the current calendar, compares and returns if this Date's is on or before the provided end Date.
     This function only compares day, month, and year
     - parameter endDate: End date to compare against
     - returns: True if this Date is on or before endDate (day, month, year)
     */
    func lessThanOrEqualToDate(_ endDate: Date) -> Bool {
        if Calendar.current.component(.year, from: self) < Calendar.current.component(.year, from: endDate) {
            return true
        } else if Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: endDate) {
            if Calendar.current.component(.month, from: self) < Calendar.current.component(.month, from: endDate) {
                return true
            } else if Calendar.current.component(.month, from: self) == Calendar.current.component(.month, from: endDate) {
                if Calendar.current.component(.day, from: self) <= Calendar.current.component(.day, from: endDate) {
                    return true
                }
            }
        }
        return false
    }
    
}
