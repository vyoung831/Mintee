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
     Returns a Date object from a String representation. The String representation is expected to be in "yyyy-MM-dd" format
     */
    static func storedStringToDate(storedString: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: storedString)
    }
    
    /**
     Returns a "yyyy-MM-dd" String representation of a Date for storing in Core Data
     */
    func toStoredString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    /**
     Returns a "MMM dd,yyyy" String representation of a Date for presenting to user
     */
    func toMYD() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.string(from: self)
    }
    
}
