//
//  SaveFormatter.swift
//  Mu
//
//  This class provides utility functions for converting Core Data save data to/from data that Views expect to use
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import Firebase

class SaveFormatter {
    
    // MARK: - DateFormatters
    
    // Static DateFormatter for converting stored date Strings to Dates
    static let storedStringToDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    // MARK: - Task type
    
    enum taskType: String, CaseIterable {
        case recurring = "Recurring"
        case specific = "Specific"
    }
    
    /**
     Returns an Int16 from a member of enum taskType for saving to persistent store.
     - parameter type: Member of enum taskType to be used by objects in memory
     - returns: Int16 saved to persistent storage that is used to represent a task type
     */
    static func taskTypeToStored(type: taskType) -> Int16 {
        switch type {
        case .recurring:
            return 0
        case .specific:
            return 1
        }
    }
    
    /**
     Returns a member of enum taskType from a stored Int16.
     - parameter storedType: Int16 saved to persistent storage that is used to represent a task type
     - returns: Member of enum taskType to be used by objects in memory
     */
    static func storedToTaskType(storedType: Int16) -> taskType? {
        switch storedType {
        case 0:
            return .recurring
        case 1:
            return .specific
        default:
            Crashlytics.crashlytics().log("SaveFormatter.storedToTaskType() attempted to convert an invalid Int16 to value of type taskType")
            Crashlytics.crashlytics().setCustomValue(storedType, forKey: "Saved Int16")
            fatalError()
        }
    }
    
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
    static func getOperatorNumber(_ op: equalityOperator) -> Int16 {
        switch op {
        case .na: return 0
        case .lt: return 1
        case .lte: return 2
        case .eq: return 3
        }
    }
    
    /**
     Returns a String from a TaskTargetSet's minOperator/maxOperator for a View to use to represent a target operator
     - parameter op: Int16 stored in TaskTargetset's minOperator or maxOperator
     - returns: String for a View to use to represent a target operator.
     */
    static func getOperatorString(_ op: Int16) -> equalityOperator {
        switch op {
        case 0: return .na
        case 1: return .lt
        case 2: return .lte
        case 3: return .eq
        default:
            Crashlytics.crashlytics().log("SaveFormatter.getOperatorString() attempted to convert an invalid Int16 to value of type equalityOperator")
            Crashlytics.crashlytics().setCustomValue(op, forKey: "Saved Int16")
            fatalError()
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
        default:
            Crashlytics.crashlytics().log("SaveFormatter.getWeekOfMonthNumber() attempted to convert an invalid String")
            fatalError()
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
        default:
            Crashlytics.crashlytics().log("SaveFormatter.getWeekOfMonthString() attempted to convert an invalid Int16")
            fatalError()
        }
    }
    
    /**
     Returns an Int16 to insert into a DayPattern's dow
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
            Crashlytics.crashlytics().log("SaveFormatter.getWeekdayNumber() attempted to convert an invalid String")
            fatalError()
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
            Crashlytics.crashlytics().log("SaveFormatter.getWeekdayString() attempted to convert an invalid String")
            fatalError()
        }
    }
    
    /**
     Returns an Int16 to insert into a DayPattern's dom
     - parameter dayOfMonth: String used by a view to represent day of month
     - returns: Int16 to store in DayPattern's dow; U=1
     */
    static func getDayOfMonthInt(_ dayOfMonth: String) -> Int16 {
        if let dom = Int16(dayOfMonth), dom <= 31, dom >= 0 {
            return dom
        } else if dayOfMonth == "Last" {
            return 0
        }
        Crashlytics.crashlytics().log("SaveFormatter.getDayOfMonthInt() attempted to convert an invalid String")
        fatalError()
    }
    
    // MARK: - Date conversion
    
    /**
     Returns a Date object from a String representation that was saved to persistent storage
     - parameter storedString: String representation of a date in  "yyyy-MM-dd" format
     - returns: Date representation of storedString
     */
    static func storedStringToDate(_ storedString: String) -> Date {
        if let date = storedStringToDateFormatter.date(from: storedString) { return date }
        else {
            Crashlytics.crashlytics().log("SaveFormatter could not convert a stored date string to Date")
            fatalError()
        }
    }
    
    /**
     Returns a "yyyy-MM-dd" String representation of a Date to be saved to persistent storage
     - parameter date: Date to convert
     - returns: String representation of a date in  "yyyy-MM-dd" format
     */
    static func dateToStoredString(_ date: Date) -> String {
        return storedStringToDateFormatter.string(from: date)
    }
    
}
