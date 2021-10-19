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
        
        let tasksFetch = try! CDCoordinator.mainContext.fetch(Task.fetchRequest())
        let tasks: Set<Task> = Set(tasksFetch)
        TaskValidator.validateTasks(tasks)
        MOC_Validator.validateUniqueTaskNames(tasks) // TASK-5
        
        let tagsFetch = try! CDCoordinator.mainContext.fetch(Tag.fetchRequest())
        let tags: Set<Tag> = Set(tagsFetch)
        TagValidator.validateTags(tags)
        MOC_Validator.validateUniqueTagNames(tags) // TAG-1
        
        let analysesFetch = try! CDCoordinator.mainContext.fetch(Analysis.fetchRequest())
        let analyses: Set<Analysis> = Set(analysesFetch)
        AnalysisValidator.validateAnalyses(analyses)
        MOC_Validator.validateAnalysesOrdering(analyses) // ANL-5
        MOC_Validator.validateUniqueAnalysisNames(analyses) // ANL-6
        
        let taskInstancesFetch = try! CDCoordinator.mainContext.fetch(TaskInstance.fetchRequest())
        let taskInstances: Set<TaskInstance> = Set(taskInstancesFetch)
        TaskInstanceValidator.validateInstances(taskInstances)
        
        let taskSummaryAnalysesFetch = try! CDCoordinator.mainContext.fetch(TaskSummaryAnalysis.fetchRequest())
        let taskSummaryAnalyses: Set<TaskSummaryAnalysis> = Set(taskSummaryAnalysesFetch)
        TaskSummaryAnalysisValidator.validateAnalyses(taskSummaryAnalyses)
        
        let ttsFetch = try! CDCoordinator.mainContext.fetch(TaskTargetSet.fetchRequest())
        let ttses: Set<TaskTargetSet> = Set(ttsFetch)
        TaskTargetSetValidator.validateTaskTargetSets(ttses)
        
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
    
    /**
     ANL-6: An Analysis' name must be unique.
     */
    static func validateUniqueAnalysisNames(_ analyses: Set<Analysis>) {
        let analysisNames = analyses.map{ $0._name }
        let duplicates = Dictionary(grouping: analysisNames, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
    /**
     TAG-1: A Tag's name must be unique.
     */
    static func validateUniqueTagNames(_ tags: Set<Tag>) {
        let tagNames = tags.map{ $0._name }
        let duplicates = Dictionary(grouping: tagNames, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
    /**
     TASK-5: A Task's name must be unique.
     */
    static func validateUniqueTaskNames(_ tasks: Set<Task>) {
        let taskNames = tasks.map{ $0._name }
        let duplicates = Dictionary(grouping: taskNames, by: {$0}).filter{ $1.count > 1 }.keys
        XCTAssert( duplicates.count == 0)
    }
    
}
