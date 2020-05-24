//
//  WeekOfMonth+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension WeekOfMonth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeekOfMonth> {
        return NSFetchRequest<WeekOfMonth>(entityName: "WeekOfMonth")
    }

    @NSManaged public var week: Int16
    @NSManaged public var taskTargetSet: TaskTargetSet?

}
