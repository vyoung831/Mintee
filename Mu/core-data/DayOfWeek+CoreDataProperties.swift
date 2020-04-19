//
//  DayOfWeek+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension DayOfWeek {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayOfWeek> {
        return NSFetchRequest<DayOfWeek>(entityName: "DayOfWeek")
    }

    @NSManaged public var dayOfWeek: Int16
    @NSManaged public var taskTargetSet: TaskTargetSet?

}
