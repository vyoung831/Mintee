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
import XCTest

class MOC_Validator {
    
    static func validate() {
        
        let tasksFetch = try! CDCoordinator.moc.fetch(Task.fetchRequest())
        let tasks = Set<Task>(tasksFetch as! [Task])
        TaskValidator.validateTasks(tasks)
        
        let tagsFetch = try! CDCoordinator.moc.fetch(Tag.fetchRequest())
        let tags = Set<Tag>(tagsFetch as! [Tag])
        TagValidator.validateTags(tags)
        
        let analysesFetch = try! CDCoordinator.moc.fetch(Analysis.fetchRequest())
        let analyses = Set<Analysis>(analysesFetch as! [Analysis])
        AnalysisValidator.validateAnalyses(analyses)
        MOC_Validator.validateAnalysesOrdering(analyses)
        
        let taskInstancesFetch = try! CDCoordinator.moc.fetch(TaskInstance.fetchRequest())
        let taskInstances = Set<TaskInstance>(taskInstancesFetch as! [TaskInstance])
        TaskInstanceValidator.validateInstances(taskInstances)
        
    }
    
    /**
     ANL-5: An Analysis' order must be either
        * -1 OR
        * A unique number greater than or equal to 0
     */
    static func validateAnalysesOrdering(_ analyses: Set<Analysis>) {
        XCTAssert( analyses.map{ $0._order < -1 }.count == 0 )
        let nonNegativeOrders = analyses.filter{ $0._order >= 0 }.map{ $0._order }
        let duplicates = Dictionary(grouping: nonNegativeOrders, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
}
