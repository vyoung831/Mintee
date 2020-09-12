//
//  TaskInstance+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 5/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TaskInstance)
public class TaskInstance: NSManagedObject {
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, date: String) {
        self.init(entity: entity, insertInto: context)
        self.date = date
    }
    
}
