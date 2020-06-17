//
//  Date+Extensions.swift
//  Mu
//
//  Created by Vincent Young on 4/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Date to String conversion
    
    static let mydFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df
    }()
    
    static let mdyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M-d-yyyy"
        return df
    }()
    
    /**
     Returns a "MMM dd,yyyy" String representation of a Date for presenting to user
     */
    static func toMYD(_ date: Date) -> String {
        return mydFormatter.string(from: date)
    }
    
    /**
     Returns a "M-d-yyyy" String representation of a Date for presenting to user
     */
    static func toMDY(_ date: Date) -> String {
        return mdyFormatter.string(from: date)
    }
    
    // MARK: - Date comparison
    
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
    
    /**
     Using the current calendar, compares and returns if this Date's is before the provided end Date.
     This function only compares day, month, and year
     - parameter endDate: End date to compare against
     - returns: True if this Date is before endDate (day, month, year)
     */
    func lessThanDate(_ endDate: Date) -> Bool {
        if Calendar.current.component(.year, from: self) < Calendar.current.component(.year, from: endDate) {
            return true
        } else if Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: endDate) {
            if Calendar.current.component(.month, from: self) < Calendar.current.component(.month, from: endDate) {
                return true
            } else if Calendar.current.component(.month, from: self) == Calendar.current.component(.month, from: endDate) {
                if Calendar.current.component(.day, from: self) < Calendar.current.component(.day, from: endDate) {
                    return true
                }
            }
        }
        return false
    }
    
}