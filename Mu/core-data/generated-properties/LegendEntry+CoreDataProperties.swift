//
//  LegendEntry+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension LegendEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegendEntry> {
        return NSFetchRequest<LegendEntry>(entityName: "LegendEntry")
    }

    @NSManaged public var color: String?
    @NSManaged public var max: Float
    @NSManaged public var maxInclusive: Bool
    @NSManaged public var min: Float
    @NSManaged public var minInclusive: Bool
    @NSManaged public var analysis: Analysis?
    @NSManaged public var taskSummaryAnalysis: TaskSummaryAnalysis?

}
