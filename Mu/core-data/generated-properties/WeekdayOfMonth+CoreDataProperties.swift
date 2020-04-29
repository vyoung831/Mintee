//
//  WeekdayOfMonth+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/29/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension WeekdayOfMonth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeekdayOfMonth> {
        return NSFetchRequest<WeekdayOfMonth>(entityName: "WeekdayOfMonth")
    }

    @NSManaged public var weekday: Int16
    @NSManaged public var week: Int16
    @NSManaged public var taskTargetSet: TaskTargetSet?

}
