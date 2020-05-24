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
     - returns: Int16 used by DayOfWeek to store weekday; M=0
     */
    static func getWeekdayNumber(weekday: String) -> Int16 {
        switch weekday {
        case "M":
            return Int16(0)
        case "T":
            return Int16(1)
        case "W":
            return Int16(2)
        case "R":
            return Int16(3)
        case "F":
            return Int16(4)
        case "S":
            return Int16(5)
        case "U":
            return Int16(6)
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
    /**
    Returns a String from a saved DayOfWeek's day (Int16) for a View to use
    - parameter weekDay: Int16 used by DayOfWeek to store weekday; M=0
    - returns: String for view to use to represent weekday
    */
    static func getWeekdayString(weekday: Int16) -> String {
        switch weekday {
        case 0:
            return "M"
        case 1:
            return "T"
        case 2:
            return "W"
        case 3:
            return "R"
        case 4:
            return "F"
        case 5:
            return "S"
        case 6:
            return "U"
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
}
