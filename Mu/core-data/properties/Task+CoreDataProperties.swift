//
//  Task+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 7/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String?
    @NSManaged public var instances: NSSet?
    @NSManaged public var tags: NSSet?
    @NSManaged public var targetSets: NSSet?
    @NSManaged public var taskSummaryAnalysis: TaskSummaryAnalysis?

}

// MARK: Generated accessors for instances
extension Task {

    @objc(addInstancesObject:)
    @NSManaged public func addToInstances(_ value: TaskInstance)

    @objc(removeInstancesObject:)
    @NSManaged public func removeFromInstances(_ value: TaskInstance)

    @objc(addInstances:)
    @NSManaged public func addToInstances(_ values: NSSet)

    @objc(removeInstances:)
    @NSManaged public func removeFromInstances(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Task {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

// MARK: Generated accessors for targetSets
extension Task {

    @objc(addTargetSetsObject:)
    @NSManaged public func addToTargetSets(_ value: TaskTargetSet)

    @objc(removeTargetSetsObject:)
    @NSManaged public func removeFromTargetSets(_ value: TaskTargetSet)

    @objc(addTargetSets:)
    @NSManaged public func addToTargetSets(_ values: NSSet)

    @objc(removeTargetSets:)
    @NSManaged public func removeFromTargetSets(_ values: NSSet)

}
