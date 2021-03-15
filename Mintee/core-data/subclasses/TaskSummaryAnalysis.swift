//
//  TaskSummaryAnalysis+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TaskSummaryAnalysis)
public class TaskSummaryAnalysis: NSManagedObject {
    
    @NSManaged private var analysisType: String?
    @NSManaged private var dateRange: Int16
    @NSManaged private var endDate: String?
    @NSManaged private var startDate: String?
    @NSManaged private var legendEntries: NSSet?
    @NSManaged private var task: Task?
    
    var _analysisType: String? { get { return self.analysisType } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _endDate: String? { get { return self.endDate } }
    var _startDate: String? { get { return self.startDate } }
    var _legendEntries: NSSet? { get { return self.legendEntries } }
    var _task: Task? { get { return self.task } }
    
}

// MARK: Generated accessors for legendEntries
extension TaskSummaryAnalysis {

    @objc(addLegendEntriesObject:)
    @NSManaged private func addToLegendEntries(_ value: LegendEntry)

    @objc(removeLegendEntriesObject:)
    @NSManaged private func removeFromLegendEntries(_ value: LegendEntry)

    @objc(addLegendEntries:)
    @NSManaged private func addToLegendEntries(_ values: NSSet)

    @objc(removeLegendEntries:)
    @NSManaged private func removeFromLegendEntries(_ values: NSSet)

}

