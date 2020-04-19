//
//  DayOfMonth+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension DayOfMonth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayOfMonth> {
        return NSFetchRequest<DayOfMonth>(entityName: "DayOfMonth")
    }

    @NSManaged public var dayOfMonth: Int16
    @NSManaged public var taskTargetSet: TaskTargetSet?

}
