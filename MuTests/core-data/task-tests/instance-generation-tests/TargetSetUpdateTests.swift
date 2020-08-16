//
//  TargetSetUpdateTests.swift
//  MuTests
//
//  This class tests scenarios where a Task is edited and TaskInstances need to be regenerated, including the following user scenarios
//  - Existing TaskTargetSets were deleted
//  - New TaskTargetSets are added
//  - New TaskTargetSets are added and existing ones are deleted
//
//  Created by Vincent Young on 6/27/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import CoreData
@testable import Mu

class TargetSetUpdateTests: XCTestCase {
    
    let dowMin: Float = 1, dowMax: Float = 2, womMin: Float = 3, womMax: Float = 4, domMin: Float = 5, domMax: Float = 6
    
    /*
     Target sets (in priority)
     - .dow TaskTargetSet with days of week = 1,2,3,6 ("U","M","T","F")
     - .wom TaskTargetSet with days of week = 3 ("T") and weeks of month = all
     - .dom TaskTargetSet with days of month = 1,2,3,4,5,6,7,8,9,10
     */
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<Int16>([1,2,3,6]), wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: dowMin, max: dowMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 1,
                             pattern: dowPattern)
    }
    func getWomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<Int16>([4]), wom: Set<Int16>([1,2,3,4,5]), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: womMin, max: womMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 3,
                             pattern: womPattern)
    }
    func getDomTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<Int16>(), wom: Set<Int16>(), dom: Set<Int16>([1,2,3,4,5,6,7,8,9,10]))
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: domMin, max: domMax,
                             minOperator: 1, maxOperator: 1,
                             priority: 5,
                             pattern: domPattern)
    }
    
    /*
     Dates from Jan 1, 2020 to Jan 1, 2021 and String representations of dates that each TaskTargetSet applies to
     */
    var task: Task!
    let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1))!
    let globalDow: Set<String> =  Set(["2020-01-03",
                                       "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-10",
                                       "2020-01-12", "2020-01-13", "2020-01-14", "2020-01-17",
                                       "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-24",
                                       "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-31",
                                       "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-07",
                                       "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-14",
                                       "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-21",
                                       "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-28",
                                       "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-06",
                                       "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-13",
                                       "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-20",
                                       "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-27",
                                       "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-03",
                                       "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-10",
                                       "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-17",
                                       "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-24",
                                       "2020-04-26", "2020-04-27", "2020-04-28", "2020-05-01",
                                       "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-08",
                                       "2020-05-10", "2020-05-11", "2020-05-12", "2020-05-15",
                                       "2020-05-17", "2020-05-18", "2020-05-19", "2020-05-22",
                                       "2020-05-24", "2020-05-25", "2020-05-26", "2020-05-29",
                                       "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-05",
                                       "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-12",
                                       "2020-06-14", "2020-06-15", "2020-06-16", "2020-06-19",
                                       "2020-06-21", "2020-06-22", "2020-06-23", "2020-06-26",
                                       "2020-06-28", "2020-06-29", "2020-06-30", "2020-07-03",
                                       "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-10",
                                       "2020-07-12", "2020-07-13", "2020-07-14", "2020-07-17",
                                       "2020-07-19", "2020-07-20", "2020-07-21", "2020-07-24",
                                       "2020-07-26", "2020-07-27", "2020-07-28", "2020-07-31",
                                       "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-07",
                                       "2020-08-09", "2020-08-10", "2020-08-11", "2020-08-14",
                                       "2020-08-16", "2020-08-17", "2020-08-18", "2020-08-21",
                                       "2020-08-23", "2020-08-24", "2020-08-25", "2020-08-28",
                                       "2020-08-30", "2020-08-31", "2020-09-01", "2020-09-04",
                                       "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-11",
                                       "2020-09-13", "2020-09-14", "2020-09-15", "2020-09-18",
                                       "2020-09-20", "2020-09-21", "2020-09-22", "2020-09-25",
                                       "2020-09-27", "2020-09-28", "2020-09-29", "2020-10-02",
                                       "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-09",
                                       "2020-10-11", "2020-10-12", "2020-10-13", "2020-10-16",
                                       "2020-10-18", "2020-10-19", "2020-10-20", "2020-10-23",
                                       "2020-10-25", "2020-10-26", "2020-10-27", "2020-10-30",
                                       "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-06",
                                       "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-13",
                                       "2020-11-15", "2020-11-16", "2020-11-17", "2020-11-20",
                                       "2020-11-22", "2020-11-23", "2020-11-24", "2020-11-27",
                                       "2020-11-29", "2020-11-30", "2020-12-01", "2020-12-04",
                                       "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-11",
                                       "2020-12-13", "2020-12-14", "2020-12-15", "2020-12-18",
                                       "2020-12-20", "2020-12-21", "2020-12-22", "2020-12-25",
                                       "2020-12-27", "2020-12-28", "2020-12-29", "2021-01-01"])
    let globalWom: Set<String> = Set(["2020-01-01", "2020-01-08", "2020-01-15", "2020-01-22", "2020-01-29",
                                      "2020-02-05", "2020-02-12", "2020-02-19", "2020-02-26",
                                      "2020-03-04", "2020-03-11", "2020-03-18", "2020-03-25",
                                      "2020-04-01", "2020-04-08", "2020-04-15", "2020-04-22", "2020-04-29",
                                      "2020-05-06", "2020-05-13", "2020-05-20", "2020-05-27",
                                      "2020-06-03", "2020-06-10", "2020-06-17", "2020-06-24",
                                      "2020-07-01", "2020-07-08", "2020-07-15", "2020-07-22", "2020-07-29",
                                      "2020-08-05", "2020-08-12", "2020-08-19", "2020-08-26",
                                      "2020-09-02", "2020-09-09", "2020-09-16", "2020-09-23", "2020-09-30",
                                      "2020-10-07", "2020-10-14", "2020-10-21", "2020-10-28",
                                      "2020-11-04", "2020-11-11", "2020-11-18", "2020-11-25",
                                      "2020-12-02", "2020-12-09", "2020-12-16", "2020-12-23", "2020-12-30"])
    let globalDom: Set<String> = Set(["2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-08", "2020-01-09", "2020-01-10",
                                      "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10",
                                      "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10",
                                      "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10",
                                      "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09", "2020-05-10",
                                      "2020-06-01", "2020-06-02", "2020-06-03", "2020-06-04", "2020-06-05", "2020-06-06", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-10",
                                      "2020-07-01", "2020-07-02", "2020-07-03", "2020-07-04", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-08", "2020-07-09", "2020-07-10",
                                      "2020-08-01", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-05", "2020-08-06", "2020-08-07", "2020-08-08", "2020-08-09", "2020-08-10",
                                      "2020-09-01", "2020-09-02", "2020-09-03", "2020-09-04", "2020-09-05", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-09", "2020-09-10",
                                      "2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-07", "2020-10-08", "2020-10-09", "2020-10-10",
                                      "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06", "2020-11-07", "2020-11-08", "2020-11-09", "2020-11-10",
                                      "2020-12-01", "2020-12-02", "2020-12-03", "2020-12-04", "2020-12-05", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-09", "2020-12-10",
                                      "2021-01-01"])
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
        task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                    insertInto: CDCoordinator.moc,
                    name: "Task",
                    tags: [],
                    startDate: startDate,
                    endDate: endDate,
                    targetSets: Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc),
                                    getWomTargetSet(CDCoordinator.moc),
                                    getDomTargetSet(CDCoordinator.moc)))
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    // MARK: - Deleting TaskTargetSets
    
    func testDeleteDow() throws {
        
        var newWom: Set<String> = globalWom
        var newDom: Set<String> = globalDom.subtracting(newWom)
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDow.union(globalWom).union(globalDom)).subtracting(newWom).subtracting(newDom)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate,
                                      endDate: endDate,
                                      targetSets: newTargetSets)
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                newWom.remove(instance.date!)
            } else if newDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                newDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newWom.count == 0)
        XCTAssert(newDom.count == 0)
        
    }
    
    func testDeleteWom() throws {
        
        var newDow: Set<String> = globalDow
        var newDom: Set<String> = globalDom.subtracting(newDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDow.union(globalWom).union(globalDom)).subtracting(newDow).subtracting(newDom)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate,
                                      endDate: endDate,
                                      targetSets: newTargetSets)
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                newDow.remove(instance.date!)
            } else if newDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                newDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(newDom.count == 0)
        
    }
    
    func testDeleteDom() throws {
        
        var newDow: Set<String> = globalDow
        var newWom: Set<String> = globalWom.subtracting(newDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc))
        
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDow.union(globalWom).union(globalDom)).subtracting(newDow).subtracting(newWom)
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate,
                                      endDate: endDate,
                                      targetSets: newTargetSets)
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                newDow.remove(instance.date!)
            } else if newWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                newWom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(newWom.count == 0)
        
    }
    
    func testDeleteAllTargetSets() throws {
        
        let newTargetSets: Set<TaskTargetSet> = []
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)})
        var expectedDelta = (globalDow.union(globalWom).union(globalDom))
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate,
                                      endDate: endDate,
                                      targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
    }
    
    // MARK: - Adding new TaskTargetSets
    
    /**
     Add a new .dow TaskTargetSet with priority = 0. TaskTargetSets by priority = [newDow, oldDow, oldWom, oldDom]
     */
    func testAddHighPriorityDow() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 0,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        )
        var oldDow: Set<String> = globalDow.subtracting(newDow)
        var oldWom: Set<String> = globalWom.subtracting(oldDow).subtracting(newDow)
        var oldDom: Set<String> = globalDom.subtracting(oldWom).subtracting(oldDow).subtracting(newDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc), newDowSet)
        
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    /**
     Add a new .dow TaskTargetSet with priority = 2. TaskTargetSets by priority = [oldDow, newDow, oldWom, oldDom]
     */
    func testAddSecondPriorityDow() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 2,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        
        var oldDow: Set<String> = globalDow
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(oldDow)
        var oldWom: Set<String> = globalWom.subtracting(newDow).subtracting(oldDow)
        var oldDom: Set<String> = globalDom.subtracting(oldWom).subtracting(newDow).subtracting(oldDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc), newDowSet)
        
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    /**
     Add a new .dow TaskTargetSet with priority = 4. TaskTargetSets by priority = [oldDow, oldWom, newDow, oldDom]
     */
    func testAddThirdPriorityDow() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 4,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        
        var oldDow: Set<String> = globalDow
        var oldWom: Set<String> = globalWom.subtracting(oldDow)
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(oldWom).subtracting(oldDow)
        var oldDom: Set<String> = globalDom.subtracting(newDow).subtracting(oldWom).subtracting(oldDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc), newDowSet)
        
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    /**
     Add a new .dow TaskTargetSet with priority = 6. TaskTargetSets by priority = [oldDow, oldWom, oldDom, newDow]
     */
    func testAddLowPriorityDow() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 6,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        
        var oldDow: Set<String> = globalDow
        var oldWom: Set<String> = globalWom.subtracting(oldDow)
        var oldDom: Set<String> = globalDom.subtracting(oldWom).subtracting(oldDow)
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(oldDom).subtracting(oldWom).subtracting(oldDow)
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), getDomTargetSet(CDCoordinator.moc), newDowSet)
        
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    /**
     Add new .dom, .wom, and .dow TaskTargetSets with respective priorities = 0,2,4
     TaskTargetSets by priority = [newDom, oldDow, newWom, oldWom, newDow, oldDom]
     */
    func testAddDomWomDowHigh() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100; let newWomMin = womMin + 100; let newWomMax = womMax + 100; let newDomMin = domMin + 100; let newDomMax = domMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 4,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        let newWomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newWomMin, max: newWomMax, minOperator: 1, maxOperator: 1, priority: 2,
                                      pattern: DayPattern(dow: Set([2,6]), wom: Set([1,3,5]), dom: Set()))
        let newDomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDomMin, max: newDomMax, minOperator: 1, maxOperator: 1, priority: 0,
                                      pattern: DayPattern(dow: Set(), wom: Set(), dom: Set([3,6,9,12,15,18,21,24,27,30])))
        
        var newDom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-09", "2020-01-12", "2020-01-15", "2020-01-18", "2020-01-21", "2020-01-24", "2020-01-27", "2020-01-30", "2020-02-03", "2020-02-06", "2020-02-09", "2020-02-12", "2020-02-15", "2020-02-18", "2020-02-21", "2020-02-24", "2020-02-27", "2020-03-03", "2020-03-06", "2020-03-09", "2020-03-12", "2020-03-15", "2020-03-18", "2020-03-21", "2020-03-24", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-09", "2020-04-12", "2020-04-15", "2020-04-18", "2020-04-21", "2020-04-24", "2020-04-27", "2020-04-30", "2020-05-03", "2020-05-06", "2020-05-09", "2020-05-12", "2020-05-15", "2020-05-18", "2020-05-21", "2020-05-24", "2020-05-27", "2020-05-30", "2020-06-03", "2020-06-06", "2020-06-09", "2020-06-12", "2020-06-15", "2020-06-18", "2020-06-21", "2020-06-24", "2020-06-27", "2020-06-30", "2020-07-03", "2020-07-06", "2020-07-09", "2020-07-12", "2020-07-15", "2020-07-18", "2020-07-21", "2020-07-24", "2020-07-27", "2020-07-30", "2020-08-03", "2020-08-06", "2020-08-09", "2020-08-12", "2020-08-15", "2020-08-18", "2020-08-21", "2020-08-24", "2020-08-27", "2020-08-30", "2020-09-03", "2020-09-06", "2020-09-09", "2020-09-12", "2020-09-15", "2020-09-18", "2020-09-21", "2020-09-24", "2020-09-27", "2020-09-30", "2020-10-03", "2020-10-06", "2020-10-09", "2020-10-12", "2020-10-15", "2020-10-18", "2020-10-21", "2020-10-24", "2020-10-27", "2020-10-30", "2020-11-03", "2020-11-06", "2020-11-09", "2020-11-12", "2020-11-15", "2020-11-18", "2020-11-21", "2020-11-24", "2020-11-27", "2020-11-30", "2020-12-03", "2020-12-06", "2020-12-09", "2020-12-12", "2020-12-15", "2020-12-18", "2020-12-21", "2020-12-24", "2020-12-27", "2020-12-30"]
        )
        var oldDow: Set<String> = globalDow.subtracting(newDom)
        var newWom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-17", "2020-01-20", "2020-01-27", "2020-01-31", "2020-02-03", "2020-02-07", "2020-02-17", "2020-02-21", "2020-02-24", "2020-02-28", "2020-03-02", "2020-03-06", "2020-03-16", "2020-03-20", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-17", "2020-04-20", "2020-04-24", "2020-04-27", "2020-05-01", "2020-05-04", "2020-05-15", "2020-05-18", "2020-05-25", "2020-05-29", "2020-06-01", "2020-06-05", "2020-06-15", "2020-06-19", "2020-06-26", "2020-06-29", "2020-07-03", "2020-07-06", "2020-07-17", "2020-07-20", "2020-07-27", "2020-07-31", "2020-08-03", "2020-08-07", "2020-08-17", "2020-08-21", "2020-08-28", "2020-08-31", "2020-09-04", "2020-09-07", "2020-09-18", "2020-09-21", "2020-09-25", "2020-09-28", "2020-10-02", "2020-10-05", "2020-10-16", "2020-10-19", "2020-10-26", "2020-10-30", "2020-11-02", "2020-11-06", "2020-11-16", "2020-11-20", "2020-11-27", "2020-11-30", "2020-12-04", "2020-12-07", "2020-12-18", "2020-12-21", "2020-12-25", "2020-12-28", "2021-01-01"]
        ).subtracting(oldDow).subtracting(newDom)
        var oldWom: Set<String> = globalWom.subtracting(newWom).subtracting(oldDow).subtracting(newDom)
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(oldWom).subtracting(newWom).subtracting(oldDow).subtracting(newDom)
        var oldDom: Set<String> = globalDom.subtracting(newDow).subtracting(oldWom).subtracting(newWom).subtracting(oldDow).subtracting(newDom)
        
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc),getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc),newDowSet,newWomSet,newDomSet)
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if newWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newWomMin) && instance.targetSet!.max == Float(newWomMax))
                newWom.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if newDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDomMin) && instance.targetSet!.max == Float(newDomMax))
                newDom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(newWom.count == 0)
        XCTAssert(newDom.count == 0)
        
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    /**
     Add new .wom, .dow, and .dom TaskTargetSets with respective priorities = 0,2,4
     TaskTargetSets by priority = [newWom, oldDow, newDow, oldWom, newDom, oldDom]
     */
    func testAddWomDowDomHigh() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100; let newWomMin = womMin + 100; let newWomMax = womMax + 100; let newDomMin = domMin + 100; let newDomMax = domMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 2,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        let newWomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newWomMin, max: newWomMax, minOperator: 1, maxOperator: 1, priority: 0,
                                      pattern: DayPattern(dow: Set([2,6]), wom: Set([1,3,5]), dom: Set()))
        let newDomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDomMin, max: newDomMax, minOperator: 1, maxOperator: 1, priority: 4,
                                      pattern: DayPattern(dow: Set(), wom: Set(), dom: Set([3,6,9,12,15,18,21,24,27,30])))
        
        var newWom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-17", "2020-01-20", "2020-01-27", "2020-01-31", "2020-02-03", "2020-02-07", "2020-02-17", "2020-02-21", "2020-02-24", "2020-02-28", "2020-03-02", "2020-03-06", "2020-03-16", "2020-03-20", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-17", "2020-04-20", "2020-04-24", "2020-04-27", "2020-05-01", "2020-05-04", "2020-05-15", "2020-05-18", "2020-05-25", "2020-05-29", "2020-06-01", "2020-06-05", "2020-06-15", "2020-06-19", "2020-06-26", "2020-06-29", "2020-07-03", "2020-07-06", "2020-07-17", "2020-07-20", "2020-07-27", "2020-07-31", "2020-08-03", "2020-08-07", "2020-08-17", "2020-08-21", "2020-08-28", "2020-08-31", "2020-09-04", "2020-09-07", "2020-09-18", "2020-09-21", "2020-09-25", "2020-09-28", "2020-10-02", "2020-10-05", "2020-10-16", "2020-10-19", "2020-10-26", "2020-10-30", "2020-11-02", "2020-11-06", "2020-11-16", "2020-11-20", "2020-11-27", "2020-11-30", "2020-12-04", "2020-12-07", "2020-12-18", "2020-12-21", "2020-12-25", "2020-12-28", "2021-01-01"]
        )
        var oldDow: Set<String> = globalDow.subtracting(newWom)
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(oldDow).subtracting(newWom)
        var oldWom: Set<String> = globalWom.subtracting(newDow).subtracting(oldDow).subtracting(newWom)
        var newDom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-09", "2020-01-12", "2020-01-15", "2020-01-18", "2020-01-21", "2020-01-24", "2020-01-27", "2020-01-30", "2020-02-03", "2020-02-06", "2020-02-09", "2020-02-12", "2020-02-15", "2020-02-18", "2020-02-21", "2020-02-24", "2020-02-27", "2020-03-03", "2020-03-06", "2020-03-09", "2020-03-12", "2020-03-15", "2020-03-18", "2020-03-21", "2020-03-24", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-09", "2020-04-12", "2020-04-15", "2020-04-18", "2020-04-21", "2020-04-24", "2020-04-27", "2020-04-30", "2020-05-03", "2020-05-06", "2020-05-09", "2020-05-12", "2020-05-15", "2020-05-18", "2020-05-21", "2020-05-24", "2020-05-27", "2020-05-30", "2020-06-03", "2020-06-06", "2020-06-09", "2020-06-12", "2020-06-15", "2020-06-18", "2020-06-21", "2020-06-24", "2020-06-27", "2020-06-30", "2020-07-03", "2020-07-06", "2020-07-09", "2020-07-12", "2020-07-15", "2020-07-18", "2020-07-21", "2020-07-24", "2020-07-27", "2020-07-30", "2020-08-03", "2020-08-06", "2020-08-09", "2020-08-12", "2020-08-15", "2020-08-18", "2020-08-21", "2020-08-24", "2020-08-27", "2020-08-30", "2020-09-03", "2020-09-06", "2020-09-09", "2020-09-12", "2020-09-15", "2020-09-18", "2020-09-21", "2020-09-24", "2020-09-27", "2020-09-30", "2020-10-03", "2020-10-06", "2020-10-09", "2020-10-12", "2020-10-15", "2020-10-18", "2020-10-21", "2020-10-24", "2020-10-27", "2020-10-30", "2020-11-03", "2020-11-06", "2020-11-09", "2020-11-12", "2020-11-15", "2020-11-18", "2020-11-21", "2020-11-24", "2020-11-27", "2020-11-30", "2020-12-03", "2020-12-06", "2020-12-09", "2020-12-12", "2020-12-15", "2020-12-18", "2020-12-21", "2020-12-24", "2020-12-27", "2020-12-30"]
        ).subtracting(oldWom).subtracting(newDow).subtracting(oldDow).subtracting(newWom)
        var oldDom: Set<String> = globalDom.subtracting(newDom).subtracting(oldWom).subtracting(newDow).subtracting(oldDow).subtracting(newWom)
        
        let newTargetSets = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc),getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc),newDowSet,newWomSet,newDomSet)
        let delta = task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)}
        XCTAssert(delta.count == 0)
        
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if oldDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(dowMin) && instance.targetSet!.max == Float(dowMax))
                oldDow.remove(instance.date!)
            } else if newWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newWomMin) && instance.targetSet!.max == Float(newWomMax))
                newWom.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if newDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDomMin) && instance.targetSet!.max == Float(newDomMax))
                newDom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(newWom.count == 0)
        XCTAssert(newDom.count == 0)
        
        XCTAssert(oldDow.count == 0)
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
    // MARK: - Deleting and adding new TaskTargetSets
    
    /**
     Delete the existing .dow TaskTargetSets and add new .wom, .dow, and .dom TaskTargetSets with respective priorities = 0,2,4
     TaskTargetSets by priority = [newWom, newDow, oldWom, newDom, oldDom]
     */
    func testAddWomDowDomDeleteDow() throws {
        
        let newDowMin = dowMin + 100; let newDowMax = dowMax + 100; let newWomMin = womMin + 100; let newWomMax = womMax + 100; let newDomMin = domMin + 100; let newDomMax = domMax + 100
        let newDowSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDowMin, max: newDowMax, minOperator: 1, maxOperator: 1, priority: 2,
                                      pattern: DayPattern(dow: Set([2]), wom: Set(), dom: Set()))
        let newWomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newWomMin, max: newWomMax, minOperator: 1, maxOperator: 1, priority: 0,
                                      pattern: DayPattern(dow: Set([2,6]), wom: Set([1,3,5]), dom: Set()))
        let newDomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: newDomMin, max: newDomMax, minOperator: 1, maxOperator: 1, priority: 4,
                                      pattern: DayPattern(dow: Set(), wom: Set(), dom: Set([3,6,9,12,15,18,21,24,27,30])))
        
        var newWom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-17", "2020-01-20", "2020-01-27", "2020-01-31", "2020-02-03", "2020-02-07", "2020-02-17", "2020-02-21", "2020-02-24", "2020-02-28", "2020-03-02", "2020-03-06", "2020-03-16", "2020-03-20", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-17", "2020-04-20", "2020-04-24", "2020-04-27", "2020-05-01", "2020-05-04", "2020-05-15", "2020-05-18", "2020-05-25", "2020-05-29", "2020-06-01", "2020-06-05", "2020-06-15", "2020-06-19", "2020-06-26", "2020-06-29", "2020-07-03", "2020-07-06", "2020-07-17", "2020-07-20", "2020-07-27", "2020-07-31", "2020-08-03", "2020-08-07", "2020-08-17", "2020-08-21", "2020-08-28", "2020-08-31", "2020-09-04", "2020-09-07", "2020-09-18", "2020-09-21", "2020-09-25", "2020-09-28", "2020-10-02", "2020-10-05", "2020-10-16", "2020-10-19", "2020-10-26", "2020-10-30", "2020-11-02", "2020-11-06", "2020-11-16", "2020-11-20", "2020-11-27", "2020-11-30", "2020-12-04", "2020-12-07", "2020-12-18", "2020-12-21", "2020-12-25", "2020-12-28", "2021-01-01"]
        )
        var newDow: Set<String> = Set(["2020-01-06", "2020-01-13", "2020-01-20", "2020-01-27", "2020-02-03", "2020-02-10", "2020-02-17", "2020-02-24", "2020-03-02", "2020-03-09", "2020-03-16", "2020-03-23", "2020-03-30", "2020-04-06", "2020-04-13", "2020-04-20", "2020-04-27", "2020-05-04", "2020-05-11", "2020-05-18", "2020-05-25", "2020-06-01", "2020-06-08", "2020-06-15", "2020-06-22", "2020-06-29", "2020-07-06", "2020-07-13", "2020-07-20", "2020-07-27", "2020-08-03", "2020-08-10", "2020-08-17", "2020-08-24", "2020-08-31", "2020-09-07", "2020-09-14", "2020-09-21", "2020-09-28", "2020-10-05", "2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02", "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", "2020-12-07", "2020-12-14", "2020-12-21", "2020-12-28"]
        ).subtracting(newWom)
        var oldWom: Set<String> = globalWom.subtracting(newDow).subtracting(newWom)
        var newDom: Set<String> = Set(["2020-01-03", "2020-01-06", "2020-01-09", "2020-01-12", "2020-01-15", "2020-01-18", "2020-01-21", "2020-01-24", "2020-01-27", "2020-01-30", "2020-02-03", "2020-02-06", "2020-02-09", "2020-02-12", "2020-02-15", "2020-02-18", "2020-02-21", "2020-02-24", "2020-02-27", "2020-03-03", "2020-03-06", "2020-03-09", "2020-03-12", "2020-03-15", "2020-03-18", "2020-03-21", "2020-03-24", "2020-03-27", "2020-03-30", "2020-04-03", "2020-04-06", "2020-04-09", "2020-04-12", "2020-04-15", "2020-04-18", "2020-04-21", "2020-04-24", "2020-04-27", "2020-04-30", "2020-05-03", "2020-05-06", "2020-05-09", "2020-05-12", "2020-05-15", "2020-05-18", "2020-05-21", "2020-05-24", "2020-05-27", "2020-05-30", "2020-06-03", "2020-06-06", "2020-06-09", "2020-06-12", "2020-06-15", "2020-06-18", "2020-06-21", "2020-06-24", "2020-06-27", "2020-06-30", "2020-07-03", "2020-07-06", "2020-07-09", "2020-07-12", "2020-07-15", "2020-07-18", "2020-07-21", "2020-07-24", "2020-07-27", "2020-07-30", "2020-08-03", "2020-08-06", "2020-08-09", "2020-08-12", "2020-08-15", "2020-08-18", "2020-08-21", "2020-08-24", "2020-08-27", "2020-08-30", "2020-09-03", "2020-09-06", "2020-09-09", "2020-09-12", "2020-09-15", "2020-09-18", "2020-09-21", "2020-09-24", "2020-09-27", "2020-09-30", "2020-10-03", "2020-10-06", "2020-10-09", "2020-10-12", "2020-10-15", "2020-10-18", "2020-10-21", "2020-10-24", "2020-10-27", "2020-10-30", "2020-11-03", "2020-11-06", "2020-11-09", "2020-11-12", "2020-11-15", "2020-11-18", "2020-11-21", "2020-11-24", "2020-11-27", "2020-11-30", "2020-12-03", "2020-12-06", "2020-12-09", "2020-12-12", "2020-12-15", "2020-12-18", "2020-12-21", "2020-12-24", "2020-12-27", "2020-12-30"]
        ).subtracting(oldWom).subtracting(newDow).subtracting(newWom)
        var oldDom: Set<String> = globalDom.subtracting(newDom).subtracting(oldWom).subtracting(newDow).subtracting(newWom)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc),newDowSet,newWomSet,newDomSet)
        var delta = Set(task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern})).map{Date.toYMDTest($0)})
        let datesStillExisting = newWom.union(newDow).union(oldWom).union(newDom).union(oldDom)
        var expectedDelta = globalDow.subtracting( datesStillExisting )
        for dateToDelete in delta {
            XCTAssert(expectedDelta.contains(dateToDelete))
            expectedDelta.remove(dateToDelete)
            delta.remove(dateToDelete)
        }
        XCTAssert(expectedDelta.count == 0)
        XCTAssert(delta.count == 0)
        task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        
        let instancesFetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        var instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        for instance in instances {
            if newDow.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDowMin) && instance.targetSet!.max == Float(newDowMax))
                newDow.remove(instance.date!)
            } else if newWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newWomMin) && instance.targetSet!.max == Float(newWomMax))
                newWom.remove(instance.date!)
            } else if oldWom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(womMin) && instance.targetSet!.max == Float(womMax))
                oldWom.remove(instance.date!)
            } else if newDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(newDomMin) && instance.targetSet!.max == Float(newDomMax))
                newDom.remove(instance.date!)
            } else if oldDom.contains(instance.date!) {
                XCTAssert(instance.targetSet!.min == Float(domMin) && instance.targetSet!.max == Float(domMax))
                oldDom.remove(instance.date!)
            } else { print(instance.date!); XCTFail() }
            CDCoordinator.moc.delete(instance)
        }
        
        instances = try CDCoordinator.moc.fetch(instancesFetchRequest)
        XCTAssert(instances.count == 0)
        XCTAssert(newDow.count == 0)
        XCTAssert(newWom.count == 0)
        XCTAssert(newDom.count == 0)
        
        XCTAssert(oldWom.count == 0)
        XCTAssert(oldDom.count == 0)
        
    }
    
}

// MARK: - updateInstances performance tests

//
//  Extension to TargetSetUpdateTests.swift
//
//  This extension performance tests updateInstance functions when TaskTargetSets are deleted
//  Tests are named after
//  - The years between startDate and endDate
//  - The number of TaskTargetSets deleted
//

extension TargetSetUpdateTests {
    
    func testPerformanceUpdateInstancesFiveYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        }
        
    }
    
    func testPerformanceUpdateInstancesTenYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        }
        
    }
    
    func testPerformanceUpdateInstancesTwentyFiveYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: endDate, targetSets: newTargetSets)
        }
        
    }
    
}

// MARK: - getDeltaInstances performance tests

//
//  Extension to TargetSetUpdateTests.swift
//
//  This extension performance tests get delta instance functions when TaskTargetSets are deleted
//  Tests are named after
//  - The years between startDate and endDate
//  - The number of TaskTargetSets deleted
//

extension TargetSetUpdateTests {
    
    func testPerformanceDeltaInstancesFiveYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern}))
        }
        
    }
    
    func testPerformanceDeltaInstancesTenYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern}))
        }
        
    }
    
    func testPerformanceDeltaInstancesTwentyFiveYearsDeleteOne() {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: endDate)
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0.pattern! as! DayPattern}))
        }
        
    }
    
}
