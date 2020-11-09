//
//  TaskTargetSet+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 6/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskTargetSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskTargetSet> {
        return NSFetchRequest<TaskTargetSet>(entityName: "TaskTargetSet")
    }

    @NSManaged public var pattern: NSObject?
    @NSManaged public var priority: Int16
    @NSManaged public var instances: NSSet?
    @NSManaged public var task: Task?

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
