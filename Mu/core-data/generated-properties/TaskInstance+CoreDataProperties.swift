//
//  TaskInstance+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 5/27/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskInstance> {
        return NSFetchRequest<TaskInstance>(entityName: "TaskInstance")
    }

    @NSManaged public var completion: Float
    @NSManaged public var date: String?
    @NSManaged public var task: Task?

}
