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
    @NSManaged private var pattern: DayPattern?
    @NSManaged private var priority: Int16
    @NSManaged private var instances: NSSet?
    @NSManaged private var task: Task?
    
    var _max: Float { get { return self.max } }
    var _maxOperator: Int16 { get { return self.maxOperator } }
    var _min: Float { get { return self.min } }
    var _minOperator: Int16 { get { return self.minOperator } }
    var _pattern: DayPattern? { get { return self.pattern } }
    var _priority: Int16 { get { return self.priority } }
    var _instances: NSSet? { get { return self.instances } }
    var _task: Task? { get { return self.task } }
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     min: Float,
                     max: Float,
                     minOperator: SaveFormatter.equalityOperator,
                     maxOperator: SaveFormatter.equalityOperator,
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
    
}

// MARK:- Generated accessors for instances

extension TaskTargetSet {
    
    @objc(addInstancesObject:)
    @NSManaged private func addToInstances(_ value: TaskInstance)
    
    @objc(removeInstancesObject:)
    @NSManaged private func removeFromInstances(_ value: TaskInstance)
    
    @objc(addInstances:)
    @NSManaged private func addToInstances(_ values: NSSet)
    
    @objc(removeInstances:)
    @NSManaged private func removeFromInstances(_ values: NSSet)
    
}

extension TaskTargetSet {
    
    /**
     Checks provided minOperator, maxOperator, and min/max values to validate against business logic.
     Corrects values where necessary, such as setting both operators to = and both values to the same value if = is present.
     Returns a tuple containing an optional error message and an optional tuple of corrected values to set in the TaskTargetSet.
     - parameter minOp: EqualityOperator that is to be set as TaskTargetSet's minOperator.
     - parameter maxOp: EqualityOperator that is to be set as TaskTargetSet's maxOperator.
     - parameter min: Float to set TaskTargetSet's min to.
     - parameter max: Float to set TaskTargetSet's max to.
     - returns: Tuple of optional errorMessage and optional tuple of correct values to set as TaskTargetSet's properties. One and only one of the tuples will be non-nil.
     */
    static func validateOperators(minOp: SaveFormatter.equalityOperator,
                                  maxOp: SaveFormatter.equalityOperator,
                                  min: Float,
                                  max: Float) -> (errorMessage: String?, operators: (minOp: Int16, maxOp: Int16, min: Float, max: Float)?) {
        
        let minOpStore = SaveFormatter.equalityOperatorToStored(minOp)
        let maxOpStore = SaveFormatter.equalityOperatorToStored(maxOp)
        let eq = SaveFormatter.equalityOperatorToStored(.eq)
        let na = SaveFormatter.equalityOperatorToStored(.na)
        
        if minOp == .eq && maxOp == .eq && min != max {
            return ("Both operators were set to equal but target values were different", nil)
        }
        
        if minOp == .eq {
            return (nil, (eq, eq, min, min))
        }; if maxOp == .eq {
            return (nil, (eq, eq, max, max))
        }
        
        switch minOp {
        case .lt:
            if maxOp == .lt || maxOp == .lte {
                return min >= max ?
                    ("Min/max were set to (lt, lt/lte) but min was greater than or equal to max", nil) :
                    (nil, (minOpStore, maxOpStore, min, max))
            } else {
                return (nil, (minOpStore, na, min, 0))
            }
        case .lte:
            switch maxOp {
            case .lt:
                return min >= max ?
                    ("Min/max were set to (lte, lt) but min was greater than or equal to max", nil) :
                    (nil, (minOpStore, maxOpStore, min, max))
            case .lte:
                if min == max {
                    return (nil, (eq, eq, min, min))
                } else {
                    return min > max ?
                        ("Min/max were set to (lte, lte) but min was greater than max", nil) :
                        (nil, (minOpStore, maxOpStore, min, max))
                }
            default:
                return (nil, (minOpStore, na, min, 0))
            }
        default:
            return maxOp == .na ?
                ("Min and max operators were both N/A", nil) :
                (nil, (na, maxOpStore, 0, max))
        }
        
    }
    
    /**
     Checks this object's DayPattern to determine if it intersects with the provided day/weekday combo
     - parameter day: day of month to check
     - parameter weekday: weekday to check; should have been obtained from a Calendar's weekday component
     - returns: True if parameters matched with this TaskTargetSet's pattern
     */
    func checkDay(day: Int16, weekday: Int16, daysInMonth: Int16) -> Bool {
        
        guard let pattern = self.pattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        
        if daysInMonth < 28 {
            Crashlytics.crashlytics().log("checkDay() in TaskTargetSet received an invalid number of daysInMonth")
            Crashlytics.crashlytics().setCustomValue(daysInMonth, forKey: "Days in month")
            fatalError()
        }
        
        switch pattern.type {
        case .dow:
            return pattern.daysOfWeek.contains(weekday)
        case .wom:
            if pattern.weeksOfMonth.contains(SaveFormatter.weekOfMonthToStored(.last)) {
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
        guard let pattern = self.pattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return pattern.daysOfWeek
    }
    
    /**
     - returns: A Set of Int16, representing the week value of each WeekOfMonth in this object's weeksOfMonth relationship
     */
    func getWeeksOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return pattern.weeksOfMonth
    }
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfMonth in this object's daysOfMonth relationship
     */
    func getDaysOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern else {
            Crashlytics.crashlytics().log("TaskTargetSet was unable to retrieve its DayPattern")
            fatalError()
        }
        return pattern.daysOfMonth
    }
    
}
