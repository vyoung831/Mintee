//
//  SaveFormatter.swift
//  Mu
//
//  This class provides util functions for converting Core Data save data to/from data that Views expect to use
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

class SaveFormatter {
    
    /**
     Returns an Int16 for an instance of DayOfWeek to use
     - parameter weekDay: String used by a view to represent weekday. Must be one of ["M","T","W","R","F","S","U"]
     - returns: Int16 used by DayOfWeek to store weekday; U=1
     */
    static func getWeekdayNumber(weekday: String) -> Int16 {
        switch weekday {
        case "U":
            return Int16(1)
        case "M":
            return Int16(2)
        case "T":
            return Int16(3)
        case "W":
            return Int16(4)
        case "R":
            return Int16(5)
        case "F":
            return Int16(6)
        case "S":
            return Int16(7)
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
    /**
    Returns a String from a saved DayOfWeek's day (Int16) for a View to use
    - parameter weekDay: Int16 used by DayOfWeek to store weekday; U=1
    - returns: String for view to use to represent weekday
    */
    static func getWeekdayString(weekday: Int16) -> String {
        switch weekday {
        case 1:
            return "U"
        case 2:
            return "M"
        case 3:
            return "T"
        case 4:
            return "W"
        case 5:
            return "R"
        case 6:
            return "F"
        case 7:
            return "S"
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
    /**
     Returns a Date object from a String representation. The String representation is expected to be in "yyyy-MM-dd" format
     */
    static func storedStringToDate(_ storedString: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: storedString)
    }
    
    /**
     Returns a "yyyy-MM-dd" String representation of a Date for storing in Core Data
     */
    static func dateToStoredString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
    
}
