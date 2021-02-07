//
//  FetchRequests.swift
//  Mu
//
//  Houses NSFetchRequests that were produced by Core Data codegen.
//
//  Created by Vincent Young on 11/10/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

extension Analysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Analysis> {
        return NSFetchRequest<Analysis>(entityName: "Analysis")
    }

}

extension LegendEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegendEntry> {
        return NSFetchRequest<LegendEntry>(entityName: "LegendEntry")
    }

}

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

}

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

}

extension TaskSummaryAnalysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskSummaryAnalysis> {
        return NSFetchRequest<TaskSummaryAnalysis>(entityName: "TaskSummaryAnalysis")
    }

}

extension TaskTargetSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskTargetSet> {
        return NSFetchRequest<TaskTargetSet>(entityName: "TaskTargetSet")
    }

}

extension TaskInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskInstance> {
        return NSFetchRequest<TaskInstance>(entityName: "TaskInstance")
    }

}

