//
//  TaskInstanceGenerationTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class TaskInstanceGenerationTests: XCTestCase {
    
    // Create .dow TaskTargetSet with days of week = 1,2,3,6 ("U","M","T","F")
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<Int16>([1,2,3,6]), wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: 1, max: 2,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: dowPattern)
    }
    
    // Create TaskTargetSet with days of week = 3 ("T") and weeks of month = all
    func getWomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<Int16>([3]), wom: Set<Int16>([1,2,3,4,5]), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: 3, max: 4,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: womPattern)
    }
    
    // Create TaskTargetSet with days of month = 1,2,3,4,5,6,7,8,9,10
    func getDomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([1,2,3,4,5,6,7,8,9,10]))
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: 5, max: 6,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: domPattern)
    }
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - setNewTargetSets tests
    
    /**
     Test TaskInstance generation for new Tasks with one .dow TaskTargetSet
     */
    func testNewTaskInstancesDow() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))!
        
        var dates: Set<String> = Set(["2019-11-01","2019-11-03","2019-11-04","2019-11-05",
                                      "2019-11-08","2019-11-10","2019-11-11","2019-11-12",
                                      "2019-11-15","2019-11-17","2019-11-18","2019-11-19",
                                      "2019-11-22","2019-11-24","2019-11-25","2019-11-26",
                                      "2019-11-29"])
        dates = dates.union(["2019-12-01","2019-12-02","2019-12-03","2019-12-06",
                             "2019-12-08","2019-12-09","2019-12-10","2019-12-13",
                             "2019-12-15","2019-12-16","2019-12-17","2019-12-20",
                             "2019-12-22","2019-12-23","2019-12-24","2019-12-27",
                             "2019-12-29","2019-12-30","2019-12-31"])
        dates = dates.union(["2020-01-03","2020-01-05","2020-01-06","2020-01-07",
                             "2020-01-10","2020-01-12","2020-01-13","2020-01-14",
                             "2020-01-17","2020-01-19","2020-01-20","2020-01-21",
                             "2020-01-24","2020-01-26","2020-01-27","2020-01-28",
                             "2020-01-31"])
        dates = dates.union(["2020-02-02","2020-02-03","2020-02-04","2020-02-07",
                             "2020-02-09","2020-02-10","2020-02-11","2020-02-14",
                             "2020-02-16","2020-02-17","2020-02-18","2020-02-21",
                             "2020-02-23","2020-02-24","2020-02-25","2020-02-28"])
        dates.insert("2020-03-01")
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getDowTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        let instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
        }
        
    }
    
    /**
     Test TaskInstance generation for new Tasks with one .wom TaskTargetSet
     */
    func testNewTaskInstancesWom() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))!
        
        var dates: Set<String> = Set(["2019-11-05","2019-11-12","2019-11-19","2019-11-26",
                                      "2019-12-03","2019-12-10","2019-12-17","2019-12-24","2019-12-31",
                                      "2020-01-07","2020-01-14","2020-01-21","2020-01-28",
                                      "2020-02-04","2020-02-11","2020-02-18","2020-02-25"])
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getWomTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        let instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
        }
        
    }
    
    /**
     Test TaskInstance generation for new Tasks with one .dom TaskTargetSet
     */
    func testNewTaskInstancesDom() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))!
        
        var dates: Set<String> = Set(["2019-11-01","2019-11-02","2019-11-03","2019-11-04","2019-11-05","2019-11-06","2019-11-07","2019-11-08","2019-11-09","2019-11-10",
                                      "2019-12-01","2019-12-02","2019-12-03","2019-12-04","2019-12-05","2019-12-06","2019-12-07","2019-12-08","2019-12-09","2019-12-10",
                                      "2020-01-01","2020-01-02","2020-01-03","2020-01-04","2020-01-05","2020-01-06","2020-01-07","2020-01-08","2020-01-09","2020-01-10",
                                      "2020-02-01","2020-02-02","2020-02-03","2020-02-04","2020-02-05","2020-02-06","2020-02-07","2020-02-08","2020-02-09","2020-02-10",
                                      "2020-03-01"])
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getDomTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        let instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
        }
        
    }
    
}
