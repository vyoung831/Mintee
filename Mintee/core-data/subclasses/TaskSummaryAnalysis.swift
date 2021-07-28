//
//  TaskSummaryAnalysis+CoreDataClass.swift
//  Mintee
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TaskSummaryAnalysis)
public class TaskSummaryAnalysis: NSManagedObject {
    
    @NSManaged private var analysisType: Int16
    @NSManaged private var dateRange: Int16
    @NSManaged private var endDate: String?
    @NSManaged private var startDate: String?
    @NSManaged private var legend: AnalysisLegend?
    @NSManaged private var task: Task?
    
    var _analysisType: Int16 { get { return self.analysisType } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _endDate: String? { get { return self.endDate } }
    var _startDate: String? { get { return self.startDate } }
    var _legend: AnalysisLegend? { get { return self.legend } }
    var _task: Task? { get { return self.task } }
    
}

