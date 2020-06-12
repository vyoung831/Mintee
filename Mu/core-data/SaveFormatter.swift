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
    
    // MARK: - DateFormatters
    
    // Static DateFormatter for converting stored date Strings to Dates
    static let storedStringToDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    // MARK: - TaskTargetSet equality operators
    
    enum equalityOperator: String, CaseIterable {
        case lt = "<"
        case lte = "<="
        case eq = "="
        case na = "N/A"
    }
    
    /**
     Returns an Int16 used to represent an operator in a TaskTargetSet
     - parameter op: String used by a view to represent a target operator.
     - returns: Int16 to store in TaskTargetSet's minOperator or maxOperator
     */
    static func getOperatorNumber(_ op: String?) -> Int16 {
        switch op {
        case "<": return 1
        case "<=": return 2
        case "=": return 3
        case nil: return 0 // N/A
        default:
            // TO-DO: Crash report
            exit(-1)
        }
    }

    /**
    Returns an String from a TaskTargetSet's minOperator/maxOperator for a View to use to represent a target operator
    - parameter op: Int16 stored in TaskTargetset's minOperator or maxOperator
    - returns: String for a View to use to represent a target operator.
    */
    static func getOperatorString(_ op: Int16) -> String? {
        switch op {
        case 0: return nil // N/A
        case 1: return "<"
        case 2: return "<="
        case 3: return "="
        default:
            // TO-DO: Crash report
            exit(-1)
        }
    }
    
    // MARK: - DayPattern data conversion
    
    /**
     Returns an Int16 to append to a DayPattern's wom
     - parameter weekDay: String used by a view to represent a week of month. Must be one of ["1st","2nd","3rd","4th","Last"]
     - returns: Int16 to store in DayPattern's wom; "Last" = 5
     */
    static func getWeekOfMonthNumber(wom: String) -> Int16 {
        switch wom {
        case "1st": return 1
        case "2nd": return 2
        case "3rd": return 3
        case "4th": return 4
        case "Last": return 5
        default: exit(-1)
        }
    }
    
    /**
     Returns a String from a DayPattern's wom (Int16) for a View to use to represent a week of month
     - parameter weekDay: Int16 in DayPattern's wom; 5 = "Last"
     - returns: String for view to use to represent week of month
     */
    static func getWeekOfMonthString(wom: Int16) -> String {
        switch wom {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        case 5: return "Last"
        default: exit(-1)
        }
    }
    
    /**
     Returns an Int16 to append to to a DayPattern's dow
     - parameter weekDay: String used by a view to represent weekday. Must be one of ["M","T","W","R","F","S","U"]
     - returns: Int16 to store in DayPattern's dow; U=1
     */
    static func getWeekdayNumber(weekday: String) -> Int16 {
        switch weekday {
        case "U": return Int16(1)
        case "M": return Int16(2)
        case "T": return Int16(3)
        case "W": return Int16(4)
        case "R": return Int16(5)
        case "F": return Int16(6)
        case "S": return Int16(7)
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
    /**
     Returns a String from a DayPattern's dow (Int16) for a View to use to represent a day of week
     - parameter weekDay: Int16 used by DayPattern's dow; U=1
     - returns: String for view to use to represent weekday
     */
    static func getWeekdayString(weekday: Int16) -> String {
        switch weekday {
        case 1: return "U"
        case 2: return "M"
        case 3: return "T"
        case 4: return "W"
        case 5: return "R"
        case 6: return "F"
        case 7: return "S"
        default:
            // TO-DO: Crash reporting
            exit(-1)
        }
    }
    
    // MARK: - Date conversion
    
    /**
     Returns a Date object from a String representation. The stored String representation is expected to be in "yyyy-MM-dd" format
     */
    static func storedStringToDate(_ storedString: String) -> Date {
        if let date = storedStringToDateFormatter.date(from: storedString) { return date }
        else {
            print("SaveFormatter could not convert a stored date string to Date")
            exit(-1)
        }
    }
    
    /**
     Returns a "yyyy-MM-dd" String representation of a Date to be stored in Core Data
     */
    static func dateToStoredString(_ date: Date) -> String {
        return storedStringToDateFormatter.string(from: date)
    }
    
}
