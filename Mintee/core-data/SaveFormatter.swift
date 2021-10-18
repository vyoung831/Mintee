//
//  SaveFormatter.swift
//  Mintee
//
//  This class provides utility functions for converting persistent store data to/from structs/enums that Views expect to use.
//  Because some classes use the allCases var to access some structs/enums, enums should conform to CaseIterable, and the order in which cases are declared in this class' enums should not be altered unless necessary.
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import Firebase

class SaveFormatter {}

// MARK: - TaskTargetSet equality operators

extension SaveFormatter {
    
    enum equalityOperator: Int16, CaseIterable {
        case lt = 1
        case lte = 2
        case eq = 3
        case na = 0
        
        var stringValue: String {
            switch self {
            case .lt: return "<"
            case .lte: return "<="
            case .eq: return "="
            case .na: return "N/A"
            }
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
    
    enum dayOfMonth: Int16, Day, CaseIterable {
        
        case one = 1, two = 2, three = 3, four = 4, five = 5
        case six = 6, seven = 7, eight = 8, nine = 9, ten = 10
        case eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15
        case sixteen = 16, seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20
        case twenty_one = 21, twenty_two = 22, twenty_three = 23, twenty_four = 24, twenty_five = 25
        case twenty_six = 26, twenty_seven = 27, twenty_eight = 28, twenty_nine = 29, thirty = 30
        case thirty_one = 31, last = 0
        
        var shortValue: String {
            return self == .last ? "Last" : String(self.rawValue)
        }
        
        var longValue: String {
            return self == .last ? "Last" : String(self.rawValue)
        }
        
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

// MARK: - Selectable types (used with SelectableTypeSection)

// MARK: - Task type

extension SaveFormatter {
    
    enum taskType: Int16, CaseIterable, SelectableType {
        
        case recurring = 0
        case specific = 1
        
        var stringValue: String {
            switch self {
            case .recurring: return "Recurring"
            case .specific: return "Specific"
            }
        }
        
    }
    
}

// MARK: - Analysis types

extension SaveFormatter {
    
    enum analysisType: Int16, CaseIterable, SelectableType {
        
        case box = 0
        case line = 1
        
        var stringValue: String {
            switch self {
            case .box: return "Box"
            case .line: return "Line"
            }
        }
        
    }
    
    /**
     Converts a persistent store Int16 to the equivalent value of type SaveFormatter.analysisType
     - parameter stored: Int16 saved to an Analysis' analysisType
     - returns: (Optional) Value of type SaveFormatter.analysisType to be used by Views or Model components.
     */
    static func storedToAnalysisType(_ stored: Int16) -> SaveFormatter.analysisType? {
        return analysisType.init(rawValue: stored)
    }
    
    /**
     Returns persistent store format of a value of type SaveFormatter.analysisType.
     - parameter type: SaveFormatter.analysisType being used in-memory.
     - returns: Int16 to store to an Analysis' analysisType.
     */
    static func analysisTypeToStored(_ type: SaveFormatter.analysisType) -> Int16 {
        return type.rawValue
    }
    
}
