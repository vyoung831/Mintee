//
//  TaskSummaryAnalysis+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskSummaryAnalysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskSummaryAnalysis> {
        return NSFetchRequest<TaskSummaryAnalysis>(entityName: "TaskSummaryAnalysis")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var analysisType: String?
    @NSManaged public var dateRange: Int16
    @NSManaged public var legendEntries: NSSet?
    @NSManaged public var task: Task?

}

// MARK: Generated accessors for legendEntries
extension TaskSummaryAnalysis {

    @objc(addLegendEntriesObject:)
    @NSManaged public func addToLegendEntries(_ value: LegendEntry)

    @objc(removeLegendEntriesObject:)
    @NSManaged public func removeFromLegendEntries(_ value: LegendEntry)

    @objc(addLegendEntries:)
    @NSManaged public func addToLegendEntries(_ values: NSSet)

    @objc(removeLegendEntries:)
    @NSManaged public func removeFromLegendEntries(_ values: NSSet)

}
