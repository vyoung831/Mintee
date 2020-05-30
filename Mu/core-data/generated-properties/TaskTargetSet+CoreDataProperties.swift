//
//  TaskTargetSet+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 5/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskTargetSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskTargetSet> {
        return NSFetchRequest<TaskTargetSet>(entityName: "TaskTargetSet")
    }

    @NSManaged public var max: Float
    @NSManaged public var maxInclusive: Bool
    @NSManaged public var min: Float
    @NSManaged public var minInclusive: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var pattern: NSObject?
    @NSManaged public var daysOfMonth: NSSet?
    @NSManaged public var daysOfWeek: NSSet?
    @NSManaged public var instances: NSSet?
    @NSManaged public var task: Task?
    @NSManaged public var weeksOfMonth: NSSet?

}

// MARK: Generated accessors for daysOfMonth
extension TaskTargetSet {

    @objc(addDaysOfMonthObject:)
    @NSManaged public func addToDaysOfMonth(_ value: DayOfMonth)

    @objc(removeDaysOfMonthObject:)
    @NSManaged public func removeFromDaysOfMonth(_ value: DayOfMonth)

    @objc(addDaysOfMonth:)
    @NSManaged public func addToDaysOfMonth(_ values: NSSet)

    @objc(removeDaysOfMonth:)
    @NSManaged public func removeFromDaysOfMonth(_ values: NSSet)

}

// MARK: Generated accessors for daysOfWeek
extension TaskTargetSet {

    @objc(addDaysOfWeekObject:)
    @NSManaged public func addToDaysOfWeek(_ value: DayOfWeek)

    @objc(removeDaysOfWeekObject:)
    @NSManaged public func removeFromDaysOfWeek(_ value: DayOfWeek)

    @objc(addDaysOfWeek:)
    @NSManaged public func addToDaysOfWeek(_ values: NSSet)

    @objc(removeDaysOfWeek:)
    @NSManaged public func removeFromDaysOfWeek(_ values: NSSet)

}

// MARK: Generated accessors for instances
extension TaskTargetSet {

    @objc(addInstancesObject:)
    @NSManaged public func addToInstances(_ value: TaskInstance)

    @objc(removeInstancesObject:)
    @NSManaged public func removeFromInstances(_ value: TaskInstance)

    @objc(addInstances:)
    @NSManaged public func addToInstances(_ values: NSSet)

    @objc(removeInstances:)
    @NSManaged public func removeFromInstances(_ values: NSSet)

}

// MARK: Generated accessors for weeksOfMonth
extension TaskTargetSet {

    @objc(addWeeksOfMonthObject:)
    @NSManaged public func addToWeeksOfMonth(_ value: WeekOfMonth)

    @objc(removeWeeksOfMonthObject:)
    @NSManaged public func removeFromWeeksOfMonth(_ value: WeekOfMonth)

    @objc(addWeeksOfMonth:)
    @NSManaged public func addToWeeksOfMonth(_ values: NSSet)

    @objc(removeWeeksOfMonth:)
    @NSManaged public func removeFromWeeksOfMonth(_ values: NSSet)

}
