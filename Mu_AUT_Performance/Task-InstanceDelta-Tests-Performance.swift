//
//  Task-InstanceDelta-Tests-Performance.swift
//  Mu_AUT_Performance
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mu
@testable import SharedTestUtils
import XCTest

class Task_InstanceDelta_Tests_Performance: XCTestCase {
    
    let getDowTargetSet = Task_InstanceDelta_Tests_Util.getDowTargetSet
    let getWomTargetSet = Task_InstanceDelta_Tests_Util.getWomTargetSet
    let getDomTargetSet = Task_InstanceDelta_Tests_Util.getDomTargetSet
    let dowMin = Task_InstanceDelta_Tests_Util.dowMin
    let dowMax = Task_InstanceDelta_Tests_Util.dowMax
    let womMin = Task_InstanceDelta_Tests_Util.womMin
    let womMax = Task_InstanceDelta_Tests_Util.womMax
    let domMin = Task_InstanceDelta_Tests_Util.domMin
    let domMax = Task_InstanceDelta_Tests_Util.domMax
    let startDate = Task_InstanceDelta_Tests_Util.startDate
    let endDate = Task_InstanceDelta_Tests_Util.endDate
    let globalDowDates = Task_InstanceDelta_Tests_Util.globalDowDates
    let globalWomDates = Task_InstanceDelta_Tests_Util.globalWomDates
    let globalDomDates = Task_InstanceDelta_Tests_Util.globalDomDates
    
    var task: Task!
    
    override func setUpWithError() throws {
        task = try Task_InstanceDelta_Tests_Util.setUp()
    }
    
    override func tearDownWithError() throws {
        Task_InstanceDelta_Tests_Util.tearDown()
    }
    
}

// MARK: - getDeltaInstancesRecurring performance tests

extension Task_InstanceDelta_Tests_Performance {
    
    // MARK: - TTS deletion tests
    
    func testPerformance_getDeltaInstancesRecurring_performance_fiveYears_deleteOneTTS() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        XCTAssertNoThrow( try task.updateRecurringInstances(startDate: startDate, endDate: endDate) )
        
        let newTargetSets = Set(arrayLiteral: try getWomTargetSet(CDCoordinator.moc),
                                try getDomTargetSet(CDCoordinator.moc))
        self.measure {
            do {
                try task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
            } catch {
                XCTFail()
            }
        }
        
        
    }
    
    func testPerformance_getDeltaInstancesRecurring_performance_tenYears_deleteOneTTS() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        XCTAssertNoThrow( try task.updateRecurringInstances(startDate: startDate, endDate: endDate) )
        
        let newTargetSets = Set(arrayLiteral: try getWomTargetSet(CDCoordinator.moc),
                                try getDomTargetSet(CDCoordinator.moc))
        self.measure {
            do {
                try task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
            } catch {
                XCTFail()
            }
        }
        
    }
    
    func testPerformance_getDeltaInstancesRecurring_performance_twentyFiveYears_deleteOneTTS() throws {
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        XCTAssertNoThrow( try task.updateRecurringInstances(startDate: startDate, endDate: endDate) )
        
        let newTargetSets = Set(arrayLiteral: try getWomTargetSet(CDCoordinator.moc),
                                try getDomTargetSet(CDCoordinator.moc))
        self.measure {
            do {
                try task.getDeltaInstancesRecurring(startDate: startDate, endDate: endDate, dayPatterns: Set(newTargetSets.map{$0._pattern!}))
            } catch {
                XCTFail()
            }
        }
        
    }
    
}
