//
//  Tag+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 5/2/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String?
    @NSManaged public var analyses: NSSet?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for analyses
extension Tag {

    @objc(addAnalysesObject:)
    @NSManaged public func addToAnalyses(_ value: Analysis)

    @objc(removeAnalysesObject:)
    @NSManaged public func removeFromAnalyses(_ value: Analysis)

    @objc(addAnalyses:)
    @NSManaged public func addToAnalyses(_ values: NSSet)

    @objc(removeAnalyses:)
    @NSManaged public func removeFromAnalyses(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension Tag {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
