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
            return nil
        }
    }
    
}

// MARK: - TaskTargetSet equality operators

extension SaveFormatter {
    
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
    static func equalityOperatorToStored(_ op: equalityOperator) -> Int16 {
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
    static func storedToEqualityOperator(_ op: Int16) -> equalityOperator? {
        switch op {
        case 0: return .na
        case 1: return .lt
        case 2: return .lte
        case 3: return .eq
        default: return nil
        }
    }
    
}

// MARK: - DayPattern day enums

protocol Day: Hashable {
    var shortValue: String { get }
    var longValue: String { get }
}

extension SaveFormatter {
    
    enum dayOfWeek: Int16, Day, CaseIterable {
        
        case monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7, sunday = 1
        
        var shortValue: String {
            get {
                switch self {
                case .monday: return "M"
                case .tuesday: return "T"
                case .wednesday: return "W"
                case .thursday: return "R"
                case .friday: return "F"
                case .saturday: return "S"
                case .sunday: return "U"
                }
            }
        }
        
        var longValue: String {
            get {
                switch self {
                case .monday: return "Monday"
                case .tuesday: return "Tuesday"
                case .wednesday: return "Wednesday"
                case .thursday: return "Thursday"
                case .friday: return "Friday"
                case .saturday: return "Saturday"
                case .sunday: return "Sunday"
                }
            }
        }
        
    }
    
    /**
     Returns persistent store format of a value of type SaveFormatter.dayOfWeek (stored in DayPattern).
     - parameter dow: Value of type SaveFormatter.dayOfWeek obtain the Int16 persistent store value of.
     - returns: Int16 representing provided SaveFormatter.dayOfWeek.
     */
    static func dayOfWeekToStored(_ dow: SaveFormatter.dayOfWeek) -> Int16 {
        return dow.rawValue
    }
    
    /**
     Converts a value from persistent store to the equivalent value of type SaveFormatter.dayOfWeek
     - parameter dow: Int16 used by DayPattern's dow; 1 = Sunday
     - returns: (Optional) Value of type SaveFormatter.dayOfWeek to be used by Views or Model objects.
     */
    static func storedToDayOfWeek(_ dow: Int16) -> dayOfWeek? {
        return SaveFormatter.dayOfWeek.init(rawValue: dow)
    }
    
    enum weekOfMonth: Int16, Day, CaseIterable {
        
        case first = 1, second = 2, third = 3, fourth = 4, last = 5
        
        var shortValue: String {
            get {
                switch self {
                case .first: return "1st"
                case .second: return "2nd"
                case .third: return "3rd"
                case .fourth: return "4th"
                case .last: return "Last"
                }
            }
        }
        
        var longValue: String {
            get {
                switch self {
                case .first: return "First"
                case .second: return "Second"
                case .third: return "Third"
                case .fourth: return "Fourth"
                case .last: return "Last"
                }
            }
        }
        
    }
    
    /**
     Returns persistent store format of a value of type SaveFormatter.weekOfMonth (stored in DayPattern).
     - parameter wom: Value of type SaveFormatter.weekOfMonth obtain the Int16 persistent store value of.
     - returns: Int16 representing provided SaveFormatter.weekOfMonth.
     */
    static func weekOfMonthToStored(_ wom: SaveFormatter.weekOfMonth) -> Int16 {
        return wom.rawValue
    }
    
    /**
     Converts a value from persistent store to the equivalent value of type SaveFormatter.weekOfMonth
     - parameter wom: Int16 in DayPattern's wom; 5 = last week of month
     - returns: (Optional) Value of type SaveFormatter.weekOfMonth to be used by Views or Model objects.
     */
    static func storedToWeekOfMonth(_ wom: Int16) -> SaveFormatter.weekOfMonth? {
        return SaveFormatter.weekOfMonth.init(rawValue: wom)
    }
    
    enum dayOfMonth: Int16, Day, CaseIterable {
        
        case one = 1, two = 2, three = 3, four = 4, five = 5
        case six = 6, seven = 7, eight = 8, nine = 9, ten = 10
        case eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15
        case sixteen = 16, seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20
        case twenty_one = 21, twenty_two = 22, twenty_three = 23, twenty_four = 24, twenty_five = 25
        case twenty_six = 26, twenty_seven = 27, twenty_eight = 28, twenty_nine = 29, thirty = 30
        case thirty_one = 31, last = 0
        
        var shortValue: String {
            return self == .last ? "last" : String(self.rawValue)
        }
        
        var longValue: String {
            return self == .last ? "last" : String(self.rawValue)
        }
        
    }
    
    /**
     Returns persistent store format of a value of type SaveFormatter.dayOfMonth (stored in DayPattern).
     - parameter dom: Value of type SaveFormatter.dayOfMonth obtain the Int16 persistent store value of.
     - returns: Int16 representing provided SaveFormatter.dayOfMonth.
     */
    static func dayOfMonthToStored(_ dom: SaveFormatter.dayOfMonth) -> Int16 {
        return dom.rawValue
    }
    
    /**
     Converts a value from persistent store to the equivalent value of type SaveFormatter.dayOfMonth
     - parameter dom: Int16 in DayPattern's dom; 0 = last day of month
     - returns: (Optional) Value of type SaveFormatter.dayOfMonth to be used by Views or Model objects.
     */
    static func storedToDayOfMonth(_ dom: Int16) -> SaveFormatter.dayOfMonth? {
        return SaveFormatter.dayOfMonth.init(rawValue: dom)
    }
    
}

// MARK: - Date conversion

extension SaveFormatter {
    
    // Static DateFormatter for converting stored date Strings to Dates
    static let storedStringToDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    /**
     Returns a "yyyy-MM-dd" String representation of a Date to be saved to persistent storage
     - parameter date: Date to convert
     - returns: String representation of a date in  "yyyy-MM-dd" format
     */
    static func dateToStoredString(_ date: Date) -> String {
        return storedStringToDateFormatter.string(from: date)
    }
    
    /**
     Returns a Date object from a String representation that was saved to persistent storage
     - parameter storedString: String representation of a date in  "yyyy-MM-dd" format
     - returns: (Optional) Date representation of the stored String representing a date
     */
    static func storedStringToDate(_ storedString: String) -> Date? {
        return storedStringToDateFormatter.date(from: storedString)
    }
    
}
