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
    @NSManaged private var task: Task
    
    @NSManaged private var instances: NSSet?
    
    var _max: Float { get { return self.max } }
    var _min: Float { get { return self.min } }
    var _pattern: DayPattern { get { return self.pattern } }
    var _priority: Int16 { get { return self.priority } }
    var _task: Task { get { return self.task } }
    
    var _instances: Set<TaskInstance> {
        get throws {
            guard let unwrappedSet = self.instances else { return Set() }
            guard let castedSet = unwrappedSet as? Set<TaskInstance> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.task.mergeDebugDictionary())
            }
            return castedSet
        }
    }
    
    var _minOperator: SaveFormatter.equalityOperator {
        get throws {
            guard let minOp = SaveFormatter.equalityOperator.init(rawValue: self.minOperator) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.task.mergeDebugDictionary())
            }
            return minOp
        }
    }
    
    var _maxOperator: SaveFormatter.equalityOperator {
        get throws {
            guard let maxOp = SaveFormatter.equalityOperator.init(rawValue: self.maxOperator) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.task.mergeDebugDictionary())
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
        do {
            let validatedValues = try TaskTargetSet.validateOperators(minOp: minOperator, maxOp: maxOperator, min: min, max: max)
            self.init(entity: entity, insertInto: context)
            self.minOperator = validatedValues.minOp.rawValue
            self.maxOperator = validatedValues.maxOp.rawValue
            self.min = validatedValues.min
            self.max = validatedValues.max
            self.priority = priority
            self.pattern = pattern
        } catch is TaskTargetSet.validateErrorCode {
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput,
                                              ["min": min, "max": max,
                                               "minOperator": minOperator.rawValue, "maxOperator": maxOperator.rawValue])
        } catch {
            throw ErrorManager.recordUnexpectedError(error)
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

// MARK: - Validation helper functions

extension TaskTargetSet {
    
    enum validateErrorCode: Error {
        case bothOperators_setToEqual_differentTargetValues
        case min_greaterThanOrEqualTo_max
        case min_greaterThan_max
        case bothOperators_notApplicable
    }
    
    /**
     Checks provided minOperator, maxOperator, and min/max values to validate against business logic.
     Returns a tuple containing an optional error message and an optional tuple of corrected values to set in the TaskTargetSet.
     - parameter minOp: Value of type SaveFormatter.equalityOperator whose persistent store format should be assigned as TaskTargetSet's minOperator.
     - parameter maxOp: Value of type SaveFormatter.equalityOperator whose persistent store format should be assigned as TaskTargetSet's maxOperator.
     - parameter min: Float to set TaskTargetSet's min to.
     - parameter max: Float to set TaskTargetSet's max to.
     - returns: Corrected values to set as TaskTargetSet's properties.
     */
    static func validateOperators(minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator,
                                  min: Float, max: Float) throws -> (minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator,
                                                                     min: Float, max: Float) {
        
        if minOp == .eq && maxOp == .eq && min != max {
            throw validateErrorCode.bothOperators_setToEqual_differentTargetValues as NSError
        }
        
        if minOp == .eq {
            return (.eq, .na, min, 0)
        }; if maxOp == .eq {
            return (.eq, .na, max, 0)
        }
        
        switch minOp {
        case .lt:
            if maxOp == .lt || maxOp == .lte {
                if min >= max {
                    throw validateErrorCode.min_greaterThanOrEqualTo_max as NSError
                }
                return (minOp, maxOp, min, max)
            } else {
                return (minOp, .na, min, 0)
            }
        case .lte:
            switch maxOp {
            case .lt:
                if min >= max {
                    throw validateErrorCode.min_greaterThanOrEqualTo_max as NSError
                }
                return (minOp, maxOp, min, max)
            case .lte:
                if min == max {
                    return (.eq, .na, min, 0)
                } else {
                    if min > max {
                        throw validateErrorCode.min_greaterThan_max as NSError
                    }
                    return (minOp, maxOp, min, max)
                }
            default:
                return (minOp, .na, min, 0)
            }
        default:
            if maxOp == .na {
                throw validateErrorCode.bothOperators_notApplicable as NSError
            }
            return (.na, maxOp, 0, max)
        }
        
    }
    
    /**
     Checks this object's DayPattern to determine if it intersects with the provided day/weekday combo
     - parameter day: day of month to check
     - parameter weekday: weekday to check; should have been obtained from a Calendar's weekday component
     - parameter daysInMonth: the number of days in the month of the date provided.
     - returns: True if parameters matched with this TaskTargetSet's pattern
     */
    func checkDay(day: Int16, weekday: Int16, daysInMonth: Int16) throws -> Bool {
        
        guard let dom = SaveFormatter.dayOfMonth.init(rawValue: day),
              let dow = SaveFormatter.dayOfWeek.init(rawValue: weekday),
              let lastWom = SaveFormatter.weekOfMonth.init(rawValue: Int16(ceil(Float(day)/7))) else {
            var userInfo: [String : Any] = ["day": day, "weekday": weekday, "daysInMonth": daysInMonth,
                                            "TaskTargetSet": self.debugDescription]
            self._task.mergeDebugDictionary(userInfo: &userInfo)
            throw ErrorManager.recordNonFatal(.modelFunction_receivedInvalidInput, userInfo)
        }
        
        switch try pattern._type {
        case .dow:
            return try pattern._daysOfWeek.contains(dow)
        case .wom:
            if try pattern._weeksOfMonth.contains(.last) {
                return try pattern._daysOfWeek.contains(dow) &&
                    (try pattern._weeksOfMonth.contains(lastWom) || day + 7 > daysInMonth)
            }
            return try pattern._daysOfWeek.contains(dow) &&
                (try pattern._weeksOfMonth.contains(lastWom))
        case .dom:
            /*
             The following conditions are checked:
             - The DayPattern's selected days of month are checked for equality to dateCounter's day, OR
             - The DayPattern's selected days of month contains `.last` and dateCounter is the last day of the month
             */
            return try pattern._daysOfMonth.contains(dom) || ( try pattern._daysOfMonth.contains(.last) && day == daysInMonth)
        }
        
    }
    
}
