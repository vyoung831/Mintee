//
//  LegendEntry+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LegendEntry)
public class LegendEntry: NSManagedObject {
    
    @NSManaged private var color: String?
    @NSManaged private var max: Float
    @NSManaged private var maxInclusive: Bool
    @NSManaged private var min: Float
    @NSManaged private var minInclusive: Bool
    @NSManaged private var analysis: Analysis?
    @NSManaged private var taskSummaryAnalysis: TaskSummaryAnalysis?
    
    var _color: String? { get { return self.color } }
    var _max: Float { get { return self.max } }
    var _maxInclusive: Bool { get { return self.maxInclusive } }
    var _min: Float { get { return self.min } }
    var _minInclusive: Bool { get { return self.minInclusive } }
    var _analysis: Analysis? { get { return self.analysis } }
    var _taskSummaryAnalysis: TaskSummaryAnalysis? { get { return self.taskSummaryAnalysis } }
    
}
