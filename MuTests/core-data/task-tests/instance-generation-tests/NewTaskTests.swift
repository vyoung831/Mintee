//
//  NewTaskTests.swift
//  MuTests
//
//  This class tests scenarios where a Task is created and new TaskInstances need to be generated.
//  The tests are named by with the types of TaskTargetSets, which are also ordered by priority in the test name.
//  Tests that deal with .dom TaskTargetSets also test with dayOfMonth value 0 (used to indicate last day of month)
//
//  Created by Vincent Young on 6/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class NewTaskTests: XCTestCase {
    
    let dowMin: Float = 1, dowMax: Float = 2, womMin: Float = 3, womMax: Float = 4, domMin: Float = 5, domMax: Float = 6
    
    /*
     Target sets
     - .dow TaskTargetSet with days of week = 1,2,3,6 ("U","M","T","F")
     - .wom TaskTargetSet with days of week = 3 ("T") and weeks of month = all
     - .dom TaskTargetSet with days of month = 0,1,2,3,4,5,6,7,8,9,10
     */
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<Int16>([1,2,3,6]), wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: dowMin, max: dowMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: dowPattern)
    }
    func getWomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<Int16>([3]), wom: Set<Int16>([1,2,3,4,5]), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: womMin, max: womMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 0,
                             pattern: womPattern)
    }
    func getDomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([0,1,2,3,4,5,6,7,8,9,10]))
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
    let endDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
    let globalDow: Set<String> =  Set(["2019-11-01", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-08", "2019-11-10", "2019-11-11", "2019-11-12", "2019-11-15", "2019-11-17", "2019-11-18", "2019-11-19", "2019-11-22", "2019-11-24", "2019-11-25", "2019-11-26", "2019-11-29", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-06", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-13", "2019-12-15", "2019-12-16", "2019-12-17", "2019-12-20", "2019-12-22", "2019-12-23", "2019-12-24", "2019-12-27", "2019-12-29", "2019-12-30", "2019-12-31", "2020-01-03", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-10", "2020-01-12", "2020-01-13", "2020-01-14", "2020-01-17", "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-24", "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-31", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-07", "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-14", "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-21", "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-28", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-06", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-13", "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-20", "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-27", "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-03", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-10", "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-17", "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-24", "2020-04-26", "2020-04-27", "2020-04-28", "2020-05-01", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-08", "2020-05-10", "2020-05-11", "2020-05-12", "2020-05-15", "2020-05-17", "2020-05-18", "2020-05-19", "2020-05-22", "2020-05-24", "2020-05-25", "2020-05-26", "2020-05-29", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-05", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-12", "2020-06-14", "2020-06-15", "2020-06-16", "2020-06-19", "2020-06-21", "2020-06-22", "2020-06-23", "2020-06-26", "2020-06-28", "2020-06-29", "2020-06-30", "2020-07-03", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-10", "2020-07-12", "2020-07-13", "2020-07-14", "2020-07-17", "2020-07-19", "2020-07-20", "2020-07-21", "2020-07-24", "2020-07-26", "2020-07-27", "2020-07-28", "2020-07-31", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-07", "2020-08-09", "2020-08-10", "2020-08-11", "2020-08-14", "2020-08-16", "2020-08-17", "2020-08-18", "2020-08-21", "2020-08-23", "2020-08-24", "2020-08-25", "2020-08-28", "2020-08-30", "2020-08-31", "2020-09-01", "2020-09-04", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-11", "2020-09-13", "2020-09-14", "2020-09-15", "2020-09-18", "2020-09-20", "2020-09-21", "2020-09-22", "2020-09-25", "2020-09-27", "2020-09-28", "2020-09-29", "2020-10-02", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-09", "2020-10-11", "2020-10-12", "2020-10-13", "2020-10-16", "2020-10-18", "2020-10-19", "2020-10-20", "2020-10-23", "2020-10-25", "2020-10-26", "2020-10-27", "2020-10-30", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-06", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-13", "2020-11-15", "2020-11-16", "2020-11-17", "2020-11-20", "2020-11-22", "2020-11-23", "2020-11-24", "2020-11-27", "2020-11-29", "2020-11-30", "2020-12-01", "2020-12-04", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-11", "2020-12-13", "2020-12-14", "2020-12-15", "2020-12-18", "2020-12-20", "2020-12-21", "2020-12-22", "2020-12-25", "2020-12-27", "2020-12-28", "2020-12-29", "2021-01-01", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-08", "2021-01-10", "2021-01-11", "2021-01-12", "2021-01-15", "2021-01-17", "2021-01-18", "2021-01-19", "2021-01-22", "2021-01-24", "2021-01-25", "2021-01-26", "2021-01-29", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-05", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-12", "2021-02-14", "2021-02-15", "2021-02-16", "2021-02-19", "2021-02-21", "2021-02-22", "2021-02-23", "2021-02-26", "2021-02-28", "2021-03-01"]
    )
    let globalWom: Set<String> = Set(["2019-11-05", "2019-11-12", "2019-11-19", "2019-11-26", "2019-12-03", "2019-12-10", "2019-12-17", "2019-12-24", "2019-12-31", "2020-01-07", "2020-01-14", "2020-01-21", "2020-01-28", "2020-02-04", "2020-02-11", "2020-02-18", "2020-02-25", "2020-03-03", "2020-03-10", "2020-03-17", "2020-03-24", "2020-03-31", "2020-04-07", "2020-04-14", "2020-04-21", "2020-04-28", "2020-05-05", "2020-05-12", "2020-05-19", "2020-05-26", "2020-06-02", "2020-06-09", "2020-06-16", "2020-06-23", "2020-06-30", "2020-07-07", "2020-07-14", "2020-07-21", "2020-07-28", "2020-08-04", "2020-08-11", "2020-08-18", "2020-08-25", "2020-09-01", "2020-09-08", "2020-09-15", "2020-09-22", "2020-09-29", "2020-10-06", "2020-10-13", "2020-10-20", "2020-10-27", "2020-11-03", "2020-11-10", "2020-11-17", "2020-11-24", "2020-12-01", "2020-12-08", "2020-12-15", "2020-12-22", "2020-12-29", "2021-01-05", "2021-01-12", "2021-01-19", "2021-01-26", "2021-02-02", "2021-02-09", "2021-02-16", "2021-02-23"]
    )
    let globalDom: Set<String> = Set(["2019-11-01", "2019-11-02", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-06", "2019-11-07", "2019-11-08", "2019-11-09", "2019-11-10", "2019-11-30", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-04", "2019-12-05", "2019-12-06", "2019-12-07", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-31", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-08", "2020-01-09", "2020-01-10", "2020-01-31", "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10", "2020-02-29", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-31", "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10", "2020-04-30", "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09", "2020-05-10", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-03", "2020-06-04", "2020-06-05", "2020-06-06", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-10", "2020-06-30", "2020-07-01", "2020-07-02", "2020-07-03", "2020-07-04", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-08", "2020-07-09", "2020-07-10", "2020-07-31", "2020-08-01", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-05", "2020-08-06", "2020-08-07", "2020-08-08", "2020-08-09", "2020-08-10", "2020-08-31", "2020-09-01", "2020-09-02", "2020-09-03", "2020-09-04", "2020-09-05", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-09", "2020-09-10", "2020-09-30", "2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-07", "2020-10-08", "2020-10-09", "2020-10-10", "2020-10-31", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06", "2020-11-07", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-30", "2020-12-01", "2020-12-02", "2020-12-03", "2020-12-04", "2020-12-05", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-09", "2020-12-10", "2020-12-31", "2021-01-01", "2021-01-02", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-06", "2021-01-07", "2021-01-08", "2021-01-09", "2021-01-10", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-03", "2021-02-04", "2021-02-05", "2021-02-06", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-10", "2021-02-28", "2021-03-01"]
    )
    
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
        
        var dowDates: Set<String> = globalDow
        var womDates: Set<String> = globalWom.subtracting(dowDates)
        
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
            
            if dowDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                dowDates.remove(instance.date!)
            } else if womDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                womDates.remove(instance.date!)
            } else { XCTFail() }
            
            CDCoordinator.moc.delete(instance)
        }
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(dowDates.count == 0)
        XCTAssert(womDates.count == 0)
        
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
        
        var dowDates: Set<String> = globalDow
        var womDates: Set<String> = globalWom.subtracting(dowDates)
        var domDates: Set<String> = globalDom.subtracting(womDates).subtracting(dowDates)
        
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
            } else if womDates.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                womDates.remove(instance.date!)
            } else if domDates.contains(instance.date!) {
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

// MARK: - Performance tests

extension NewTaskTests {
    
    func test5y3tts() {
        
        let start = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        let dow = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set<Int16>([2,4,6]), wom: Set<Int16>(), dom: Set<Int16>()))
        let wom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 1,
                                pattern: DayPattern(dow: Set<Int16>([1,3,5,7]), wom: Set<Int16>([2,4]), dom: Set<Int16>()))
        let dom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 2,
                                pattern: DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([3,6,9,12,15,18,21,24])))
        
        self.measure {
            let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
            insertInto: CDCoordinator.moc,
            name: "Task",
            tags: [],
            startDate: start, endDate: end,
            targetSets: [dow,wom,dom])
        }
        
    }
    
    func test25y1tts() {
        
        let start = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        
        let dom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([3,6,9,12,15,18,21,24])))
        
        self.measure {
            let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
            insertInto: CDCoordinator.moc,
            name: "Task",
            tags: [],
            startDate: start, endDate: end,
            targetSets: [dom])
        }
        
    }
    
    func test25y3tts() {
        
        let start = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        
        let dow = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set<Int16>([2,4,6]), wom: Set<Int16>(), dom: Set<Int16>()))
        let wom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 1,
                                pattern: DayPattern(dow: Set<Int16>([1,3,5,7]), wom: Set<Int16>([2,4]), dom: Set<Int16>()))
        let dom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 2,
                                pattern: DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([3,6,9,12,15,18,21,24])))
        
        self.measure {
            let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
            insertInto: CDCoordinator.moc,
            name: "Task",
            tags: [],
            startDate: start, endDate: end,
            targetSets: [dow,wom,dom])
        }
        
    }
    
    /**
     Test 25 years and 3 TaskTargetSets with every dom selected
     */
    func test25y3ttsFull() {
        
        let start = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        
        let dow = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 0,
                                pattern: DayPattern(dow: Set<Int16>([1]), wom: Set<Int16>(), dom: Set<Int16>()))
        let wom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 1,
                                pattern: DayPattern(dow: Set<Int16>([1]), wom: Set<Int16>([1]), dom: Set<Int16>()))
        let dom = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                insertInto: CDCoordinator.moc,
                                min: 0, max: 1, minOperator: 1, maxOperator: 1, priority: 2,
                                pattern: DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31])))
        
        self.measure {
            let _ = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
            insertInto: CDCoordinator.moc,
            name: "Task",
            tags: [],
            startDate: start, endDate: end,
            targetSets: [dow,wom,dom])
        }
        
    }
    
}
