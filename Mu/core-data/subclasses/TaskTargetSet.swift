//
//  TaskTargetSet+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData
import Firebase

@objc(TaskTargetSet)
public class TaskTargetSet: NSManagedObject {
    
    @NSManaged private var max: Float
    @NSManaged private var maxOperator: Int16
    @NSManaged private var min: Float
    @NSManaged private var minOperator: Int16
    
    var getMin: Float {
        get {
            return min
        }
    }
    
    var getMax: Float {
        get {
            return min
        }
    }
    
    var getMinOperator: Int16 {
        get {
            return minOperator
        }
    }
    
    var getMaxOperator: Int16 {
        get {
            return maxOperator
        }
    }
    
    /**
     Calls function of the same name in TaskTargetSet that takes minOp and maxOp as Int16 instead of SaveFormatter.EqualityOperator.
     Checks provided minOperator, maxOperator, and min/max values to determine if combination is valid. Corrects values where necessary, such as setting both operators to = and both values to the same value if = is present.
     Returns a tuple containing an optional error message and an optional tuple of corrected values to set in the TaskTargetSet.
     - parameter minOp: EqualityOperator that is to be set as TaskTargetSet's minOperator
     - parameter maxOp: EqualityOperator that is to be set as TaskTargetSet's maxOperator
     - parameter minTarget: Float to set TaskTargetSet's min to
     - parameter maxTarget: Float to set TaskTargetSet's max to
     - returns: Tuple of optional errorMessage and optional tuple of correct values to set in TaskTargetSet. One and only one of the tuples will be non-nil
     */
    static func validateOperators(minOperator: SaveFormatter.equalityOperator,
                                  maxOperator: SaveFormatter.equalityOperator,
                                  min: Float,
                                  max: Float) -> (errorMessage: String?, operators: (minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator, min: Float, max: Float)?) {
        
        let validatedValues = TaskTargetSet.validateOperators(minOp: SaveFormatter.getOperatorNumber(minOperator),
                                                              maxOp: SaveFormatter.getOperatorNumber(maxOperator),
                                                              min: min,
                                                              max: max)
        if let validatedOperators = validatedValues.operators {
            return (validatedValues.errorMessage, (minOp: SaveFormatter.getOperatorString(validatedOperators.minOp),
                                                   maxOp: SaveFormatter.getOperatorString(validatedOperators.maxOp),
                                                   min: validatedOperators.min,
                                                   max: validatedOperators.max))
        }
        return (validatedValues.errorMessage, nil)
    }
    
    /**
     Checks provided minOperator, maxOperator, and min/max values to determine if combination is valid. Corrects values where necessary, such as setting both operators to = and both values to the same value if = is present.
     Returns a tuple containing an optional error message and an optional tuple of corrected values to set in the TaskTargetSet.
     - parameter minOp: EqualityOperator whose Int16 equivalent is to be set as TaskTargetSet's minOperator
     - parameter maxOp: EqualityOperator whose Int16 equivalent is to be set as TaskTargetSet's minOperator
     - parameter minTarget: Float to set TaskTargetSet's min to
     - parameter maxTarget: Float to set TaskTargetSet's max to
     - returns: Tuple of optional errorMessage and optional tuple of correct values to set in TaskTargetSet. One and only one of the tuples will be non-nil
     */
    static func validateOperators(minOp: Int16,
                                  maxOp: Int16,
                                  min: Float,
                                  max: Float) -> (errorMessage: String?, operators: (minOp: Int16, maxOp: Int16, min: Float, max: Float)?) {
        
        let minOperator = SaveFormatter.getOperatorString(minOp)
        let maxOperator = SaveFormatter.getOperatorString(maxOp)
        let eq = SaveFormatter.getOperatorNumber(.eq)
        let na = SaveFormatter.getOperatorNumber(.na)
        
        if minOperator == .eq && maxOperator == .eq && min != max {
            return ("Both operators were set to equal but target values were different", nil)
        }
        
        if minOperator == .eq {
            return (nil, (eq, eq, min, min))
        }; if maxOperator == .eq {
            return (nil, (eq, eq, max, max))
        }
        
        switch minOperator {
        case .lt:
            if maxOperator == .lt || maxOperator == .lte {
                return min >= max ?
                    ("Min/max were set to (lt, lt/lte) but min was greater than or equal to max", nil) :
                    (nil, (minOp, maxOp, min, max))
            } else {
                return (nil, (minOp, na, min, 0))
            }
        case .lte:
            switch maxOperator {
            case .lt:
                return min >= max ?
                    ("Min/max were set to (lte, lt) but min was greater than or equal to max", nil) :
                    (nil, (minOp, maxOp, min, max))
            case .lte:
                if min == max {
                    return (nil, (eq, eq, min, min))
                } else {
                    return min > max ?
                        ("Min/max were set to (lte, lte) but min was greater than max", nil) :
                        (nil, (minOp, maxOp, min, max))
                }
            default:
                return (nil, (minOp, na, min, 0))
            }
        default:
            return maxOp == na ?
                ("Min and max operators were both N/A", nil) :
                (nil, (na, maxOp, 0, max))
        }
        
    }
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     min: Float,
                     max: Float,
                     minOperator: Int16,
                     maxOperator: Int16,
                     priority: Int16,
                     pattern: DayPattern) {
        if let validatedValues = TaskTargetSet.validateOperators(minOp: minOperator, maxOp: maxOperator, min: min, max: max).operators {
            self.init(entity: entity, insertInto: context)
            self.minOperator = validatedValues.minOp
            self.maxOperator = validatedValues.maxOp
            self.min = validatedValues.min
            self.max = validatedValues.max
            self.priority = priority
            self.pattern = pattern
        } else {
            Crashlytics.crashlytics().log("An attempt was made to instantiate a TaskTargetSet with invalid data")
            fatalError()
        }
    }
    
    /**
     Checks this object's DayPattern to determine if it intersects with the provided day/weekday combo
     - parameter day: day of month to check
     - parameter weekday: weekday to check; should have been obtained from a Calendar's weekday component
     - returns: True if parameters matched with this TaskTargetSet's pattern
     */
    func checkDay(day: Int16, weekday: Int16, daysInMonth: Int16) -> Bool {
        
        guard let pattern = self.pattern as? DayPattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        
        if daysInMonth < 28 {
            Crashlytics.crashlytics().log("checkDay() in TaskTargetSet received an invalid number of daysInMonth")
            Crashlytics.crashlytics().setValue(daysInMonth, forKey: "Days in month")
            fatalError()
        }
        
        switch pattern.type {
        case .dow:
            return pattern.daysOfWeek.contains(weekday)
        case .wom:
            if pattern.weeksOfMonth.contains(SaveFormatter.getWeekOfMonthNumber(wom: "Last")) {
                return pattern.daysOfWeek.contains(weekday) &&
                    (pattern.weeksOfMonth.contains( Int16( ceil( Float(day)/7 )) ) || day + 7 > daysInMonth)
            }
            return pattern.daysOfWeek.contains(weekday) &&
                (pattern.weeksOfMonth.contains( Int16( ceil( Float(day)/7 )) ))
        case .dom:
            /*
             Last day of month is represented as 0, so the following conditions are checked
             - The DayPattern's selected days of month are checked for equality to dateCounter's day, OR
             - The DayPattern's selected days of month contains 0 and dateCounter is the last day of the month
             */
            return pattern.daysOfMonth.contains(day) || ( pattern.daysOfMonth.contains(0) && day == daysInMonth)
        }
        
    }
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfWeek in this object's daysOfWeek relationship
     */
    func getDaysOfWeek() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return Set(pattern.daysOfWeek)
    }
    
    /**
     - returns: A Set of Int16, representing the week value of each WeekOfMonth in this object's weeksOfMonth relationship
     */
    func getWeeksOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return Set(pattern.weeksOfMonth)
    }
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfMonth in this object's daysOfMonth relationship
     */
    func getDaysOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return Set(pattern.daysOfMonth)
    }
    
}
