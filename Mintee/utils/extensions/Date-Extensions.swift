//
//  Date+Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 4/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import Firebase

extension Date {
    
    // MARK: - Date to String conversion
    
    static let mdyPresentFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df
    }()
    
    static let mdyShortFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M-d-yyyy"
        return df
    }()
    
    /**
     Returns a "MMM d, yyyy" String representation of a Date for presenting to user
     */
    static func toMDYPresent(_ date: Date) -> String {
        return mdyPresentFormatter.string(from: date)
    }
    
    /**
     Returns a "M-d-yyyy" String representation of a Date.
     Used to present dates to the user when confirming deletion of TaskInstances
     */
    static func toMDYShort(_ date: Date) -> String {
        return mdyShortFormatter.string(from: date)
    }
    
    // MARK: - Date comparison
    
    /**
     Using the current calendar, returns the number of calendar days from the current date to the endDate
     - parameter endDate: End date to compare against
     - returns: (Optional) Number of calendar days to end date
     */
    func daysToDate(_ endDate: Date) -> Int? {
        
        let startComponents = Calendar.current.dateComponents(Set(arrayLiteral: .day, .month, .year), from: self)
        let endComponents = Calendar.current.dateComponents(Set(arrayLiteral: .day, .month, .year), from: endDate)
        guard let startCalendarDate = Calendar.current.date(from: startComponents),
              let endCalendarDate = Calendar.current.date(from: endComponents) else {
            return nil
        }
        
        if let days = Calendar.current.dateComponents(Set(arrayLiteral: .day), from: startCalendarDate, to: endCalendarDate).day {
            return days
        } else {
            return nil
        }
        
    }
    
    /**
     Using the current calendar, compares and returns if this Date's day, month, and year are equal to that of another Date's.
     - parameter compareDate: Date to compare against.
     - returns: True if this Date's day, month, and year are equal to the provided Date.
     */
    func equalToDate(_ compareDate: Date) -> Bool {
        return Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: compareDate) &&
        Calendar.current.component(.month, from: self) == Calendar.current.component(.month, from: compareDate) &&
        Calendar.current.component(.day, from: self) <= Calendar.current.component(.day, from: compareDate)
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
