//
//  LegendEntry+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension LegendEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegendEntry> {
        return NSFetchRequest<LegendEntry>(entityName: "LegendEntry")
    }

    @NSManaged public var legendEntryColor: String?
    @NSManaged public var legendEntryMax: Float
    @NSManaged public var legendEntryMaxInclusive: Bool
    @NSManaged public var legendEntryMin: Float
    @NSManaged public var legendEntryMinInclusive: Bool
    @NSManaged public var analysis: Analysis?
    @NSManaged public var taskSummaryAnalysis: TaskSummaryAnalysis?

}
