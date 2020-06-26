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
    
    let dowMin: Float = 1, dowMax: Float = 2, womMin: Float = 3, womMax: Float = 4, domMin: Float = 5, domMax: Float = 6
    
    // Create .dow TaskTargetSet with days of week = 1,2,3,6 ("U","M","T","F")
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<Int16>([1,2,3,6]), wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: dowMin, max: dowMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: dowPattern)
    }
    
    // Create TaskTargetSet with days of week = 3 ("T") and weeks of month = all
    func getWomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<Int16>([3]), wom: Set<Int16>([1,2,3,4,5]), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: womMin, max: womMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: womPattern)
    }
    
    // Create TaskTargetSet with days of month = 1,2,3,4,5,6,7,8,9,10
    func getDomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([1,2,3,4,5,6,7,8,9,10]))
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: domMin, max: domMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: domPattern)
    }
    
    /*
     Dates from Nov 1, 2019 to March 1, 2020 and String representations of dates that each TaskTargetSet applies to
     */
    let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 1))!
    let globalDow: Set<String> =  Set(["2019-11-01","2019-11-03","2019-11-04","2019-11-05",
                                       "2019-11-08","2019-11-10","2019-11-11","2019-11-12",
                                       "2019-11-15","2019-11-17","2019-11-18","2019-11-19",
                                       "2019-11-22","2019-11-24","2019-11-25","2019-11-26",
                                       "2019-11-29",
                                       "2019-12-01","2019-12-02","2019-12-03","2019-12-06",
                                       "2019-12-08","2019-12-09","2019-12-10","2019-12-13",
                                       "2019-12-15","2019-12-16","2019-12-17","2019-12-20",
                                       "2019-12-22","2019-12-23","2019-12-24","2019-12-27",
                                       "2019-12-29","2019-12-30","2019-12-31",
                                       "2020-01-03","2020-01-05","2020-01-06","2020-01-07",
                                       "2020-01-10","2020-01-12","2020-01-13","2020-01-14",
                                       "2020-01-17","2020-01-19","2020-01-20","2020-01-21",
                                       "2020-01-24","2020-01-26","2020-01-27","2020-01-28",
                                       "2020-01-31",
                                       "2020-02-02","2020-02-03","2020-02-04","2020-02-07",
                                       "2020-02-09","2020-02-10","2020-02-11","2020-02-14",
                                       "2020-02-16","2020-02-17","2020-02-18","2020-02-21",
                                       "2020-02-23","2020-02-24","2020-02-25","2020-02-28",
                                       "2020-03-01"])
    let globalWom: Set<String> = Set(["2019-11-05","2019-11-12","2019-11-19","2019-11-26",
                                      "2019-12-03","2019-12-10","2019-12-17","2019-12-24","2019-12-31",
                                      "2020-01-07","2020-01-14","2020-01-21","2020-01-28",
                                      "2020-02-04","2020-02-11","2020-02-18","2020-02-25"])
    let globalDom: Set<String> = Set(["2019-11-01","2019-11-02","2019-11-03","2019-11-04","2019-11-05","2019-11-06","2019-11-07","2019-11-08","2019-11-09","2019-11-10",
                                      "2019-12-01","2019-12-02","2019-12-03","2019-12-04","2019-12-05","2019-12-06","2019-12-07","2019-12-08","2019-12-09","2019-12-10",
                                      "2020-01-01","2020-01-02","2020-01-03","2020-01-04","2020-01-05","2020-01-06","2020-01-07","2020-01-08","2020-01-09","2020-01-10",
                                      "2020-02-01","2020-02-02","2020-02-03","2020-02-04","2020-02-05","2020-02-06","2020-02-07","2020-02-08","2020-02-09","2020-02-10",
                                      "2020-03-01"])
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - TaskInstance generation with single TaskTargetSet
    
    func testNewTaskInstancesDow() throws {
        
        var dates: Set<String> = globalDow
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getDowTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dates.count == 0)
        
    }
    
    func testNewTaskInstancesWom() throws {
        
        var dates: Set<String> = globalWom
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getWomTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dates.count == 0)
        
    }
    
    func testNewTaskInstancesDom() throws {
        
        var dates: Set<String> = globalDom
        
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [getDomTargetSet(CDCoordinator.moc)])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            XCTAssert(dates.contains(instance.date!))
            dates.remove(instance.date!)
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dates.count == 0)
        
    }
    
    // MARK: - TaskInstance generation tests with 2 TaskTargetSets
    
    func testNewTaskInstancesDowWom() throws {
        
        // Only dow dates will be compared because all selected woms (lower priority) land on selected dows
        var dowDates: Set<String> = globalDow
        
        let dow = getDowTargetSet(CDCoordinator.moc); dow.priority = 0
        let wom = getWomTargetSet(CDCoordinator.moc); wom.priority = 1
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [dow,wom])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            XCTAssert(dowDates.contains(instance.date!))
            dowDates.remove(instance.date!)
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dowDates.count == 0)
        
    }
    
    func testNewTaskInstancesWomDom() throws {
        
        var womDates: Set<String> = globalWom
        var domDates: Set<String> = globalDom.subtracting(womDates)
        
        let wom = getWomTargetSet(CDCoordinator.moc); wom.priority = 0
        let dom = getDomTargetSet(CDCoordinator.moc); dom.priority = 1
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [wom,dom])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            
            if womDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                womDates.remove(instance.date!)
            }
            else if domDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                domDates.remove(instance.date!)
            }
            else { XCTFail() }
            
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(womDates.count == 0)
        XCTAssert(domDates.count == 0)
        
    }
    
    // MARK: - TaskInstance generation tests with 3 TaskTargetSets
    
    func testNewTaskInstancesDowWomDom() throws {
        
        // wom dates aren't compared because all selected woms intersect with selected dows (higher priority)
        var dowDates: Set<String> = globalDow
        var domDates: Set<String> = globalDom.subtracting(dowDates)
        
        let dow = getDowTargetSet(CDCoordinator.moc); dow.priority = 0
        let wom = getWomTargetSet(CDCoordinator.moc); wom.priority = 1
        let dom = getDomTargetSet(CDCoordinator.moc); dom.priority = 2
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [dow,wom,dom])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            
            if dowDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                dowDates.remove(instance.date!)
            }
            else if domDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                domDates.remove(instance.date!)
            }
            else { XCTFail() }
            
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dowDates.count == 0)
        XCTAssert(domDates.count == 0)
        
    }
    
    func testNewTaskInstancesDomWomDow() throws {
        
        var domDates: Set<String> = globalDom
        var womDates: Set<String> = globalWom.subtracting(domDates)
        var dowDates: Set<String> = (globalDow.subtracting(domDates)).subtracting(womDates)
        
        let dom = getDomTargetSet(CDCoordinator.moc); dom.priority = 0
        let wom = getWomTargetSet(CDCoordinator.moc); wom.priority = 1
        let dow = getDowTargetSet(CDCoordinator.moc); dow.priority = 2
        let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                     insertInto: CDCoordinator.moc,
                     name: "Task",
                     tags: ["Tag1"],
                     startDate: startDate,
                     endDate: endDate,
                     targetSets: [dow,dom,wom])
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        
        for instance in instances {
            
            if domDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                domDates.remove(instance.date!)
            }
            else if womDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                womDates.remove(instance.date!)
            }
            else if dowDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                dowDates.remove(instance.date!)
            }
            else { XCTFail() }
            
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dowDates.count == 0)
        XCTAssert(domDates.count == 0)
        XCTAssert(womDates.count == 0)
        
    }
    
}
