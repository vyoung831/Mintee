//
//  MOC-Validator.swift
//  Mintee_AUT_Function
//
//  Created by Vincent Young on 5/26/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mintee
import Foundation
import CoreData

class MOC_Validator {
    
    static func validate() {
        
        let tasksFetch = try! CDCoordinator.moc.fetch(Task.fetchRequest())
        let tasks = Set<Task>(tasksFetch as! [Task])
        TaskValidator.validateTasks(tasks)
        
        let tagsFetch = try! CDCoordinator.moc.fetch(Tag.fetchRequest())
        let tags = Set<Tag>(tagsFetch as! [Tag])
        TagValidator.validateTags(tags)
        
    }
    
}