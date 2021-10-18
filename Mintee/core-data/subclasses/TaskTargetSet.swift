//
//  TaskTargetSet+CoreDataClass.swift
//  Mintee
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
    @NSManaged private var pattern: DayPattern
    @NSManaged private var priority: Int16
    @NSManaged private var instances: NSSet?
    @NSManaged private var task: Task
    
    var _max: Float { get { return self.max } }
    var _min: Float { get { return self.min } }
    var _pattern: DayPattern { get { return self.pattern } }
    var _priority: Int16 { get { return self.priority } }
    var _instances: NSSet? { get { return self.instances } }
    var _task: Task { get { return self.task } }
    
    var _minOperator: SaveFormatter.equalityOperator? {
        get {
            guard let minOp = SaveFormatter.equalityOperator.init(rawValue: self.minOperator) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    self.task.mergeDebugDictionary("A TaskTargetSet's minOperator could not be converted to a value of type equalityOperator"))
                return nil
            }
            return minOp
        }
    }
    
    var _maxOperator: SaveFormatter.equalityOperator? {
        get {
            guard let maxOp = SaveFormatter.equalityOperator.init(rawValue: self.maxOperator) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    self.task.mergeDebugDictionary("A TaskTargetSet's maxOperator could not be converted to a value of type equalityOperator"))
                return nil
            }
            return maxOp
        }
    }
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     min: Float, max: Float,
                     minOperator: SaveFormatter.equalityOperator, maxOperator: SaveFormatter.equalityOperator,
                     priority: Int16,
                     pattern: DayPattern) throws {
        if let validatedValues = TaskTargetSet.validateOperators(minOp: minOperator, maxOp: maxOperator, min: min, max: max).operators {
            self.init(entity: entity, insertInto: context)
            self.minOperator = validatedValues.minOp.rawValue
            self.maxOperator = validatedValues.maxOp.rawValue
            self.min = validatedValues.min
            self.max = validatedValues.max
            self.priority = priority
            self.pattern = pattern
        } else {
            var userInfo: [String : Any] = ["Message" : "TaskTargetSet.init() failed to validate operators",
                                            "min" : min,
                                            "max" : max,
                                            "minOperator" : minOperator,
                                            "maxOperator" : maxOperator,
                                            "priority" : priority]
            pattern.mergeDebugDictionary(userInfo: &userInfo)
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput, userInfo)
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

// MARK: - Debug descriptions for error reporting

extension TaskTargetSet {
    
}

// MARK: - Validation helper functions

extension TaskTargetSet {
    
    /**
     Checks provided minOperator, maxOperator, and min/max values to validate against business logic.
     Returns a tuple containing an optional error message and an optional tuple of corrected values to set in the TaskTargetSet.
     - parameter minOp: Value of type SaveFormatter.equalityOperator whose persistent store format should be assigned as TaskTargetSet's minOperator.
     - parameter maxOp: Value of type SaveFormatter.equalityOperator whose persistent store format should be assigned as TaskTargetSet's maxOperator.
     - parameter min: Float to set TaskTargetSet's min to.
     - parameter max: Float to set TaskTargetSet's max to.
     - returns: Tuple of optional errorMessage and optional tuple of correct values to set as TaskTargetSet's properties. One and only one of the tuples will be non-nil.
     */
    static func validateOperators(minOp: SaveFormatter.equalityOperator,
                                  maxOp: SaveFormatter.equalityOperator,
                                  min: Float,
                                  max: Float) -> (errorMessage: String?, operators: (minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator, min: Float, max: Float)?) {
        
        if minOp == .eq && maxOp == .eq && min != max {
            return ("Both operators were set to equal but target values were different", nil)
        }
        
        if minOp == .eq {
            return (nil, (.eq, .na, min, 0))
        }; if maxOp == .eq {
            return (nil, (.eq, .na, max, 0))
        }
        
        switch minOp {
        case .lt:
            if maxOp == .lt || maxOp == .lte {
                return min >= max ?
                    ("Min/max were set to (lt, lt/lte) but min was greater than or equal to max", nil) :
                    (nil, (minOp, maxOp, min, max))
            } else {
                return (nil, (minOp, .na, min, 0))
            }
        case .lte:
            switch maxOp {
            case .lt:
                return min >= max ?
                    ("Min/max were set to (lte, lt) but min was greater than or equal to max", nil) :
                    (nil, (minOp, maxOp, min, max))
            case .lte:
                if min == max {
                    return (nil, (.eq, .na, min, 0))
                } else {
                    return min > max ?
                        ("Min/max were set to (lte, lte) but min was greater than max", nil) :
                        (nil, (minOp, maxOp, min, max))
                }
            default:
                return (nil, (minOp, .na, min, 0))
            }
        default:
            return maxOp == .na ?
                ("Min and max operators were both N/A", nil) :
                (nil, (.na, maxOp, 0, max))
        }
        
    }
    
    /**
     Checks this object's DayPattern to determine if it intersects with the provided day/weekday combo
     - parameter day: day of month to check
     - parameter weekday: weekday to check; should have been obtained from a Calendar's weekday component
     - returns: True if parameters matched with this TaskTargetSet's pattern
     */
    func checkDay(day: Int16, weekday: Int16, daysInMonth: Int16) throws -> Bool {
        
        if daysInMonth < 28 {
            var userInfo: [String : Any] = ["Message" : "TaskTargetSet.checkDay() received daysInMonth that was less than 28",
                                            "day" : day,
                                            "weekday" : weekday,
                                            "daysInMonth" : daysInMonth,
                                            "TaskTargetSet" : self.debugDescription]
            self._task.mergeDebugDictionary(userInfo: &userInfo)
            throw ErrorManager.recordNonFatal(.modelFunction_receivedInvalidInput, userInfo)
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
    
}
