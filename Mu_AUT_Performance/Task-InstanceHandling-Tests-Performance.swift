//
//  Task-InstanceHandling-Tests-Performance.swift
//  Mu_AUT_Performance
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mu
@testable import SharedTestUtils
import XCTest

class Task_InstanceHandling_Tests_Performance: XCTestCase {

    let getDowTargetSet = Task_InstanceHandling_Tests_Util.getDowTargetSet
    let getWomTargetSet = Task_InstanceHandling_Tests_Util.getWomTargetSet
    let getDomTargetSet = Task_InstanceHandling_Tests_Util.getDomTargetSet
    let dowMin = Task_InstanceHandling_Tests_Util.dowMin
    let dowMax = Task_InstanceHandling_Tests_Util.dowMax
    let womMin = Task_InstanceHandling_Tests_Util.womMin
    let womMax = Task_InstanceHandling_Tests_Util.womMax
    let domMin = Task_InstanceHandling_Tests_Util.domMin
    let domMax = Task_InstanceHandling_Tests_Util.domMax
    let startDate = Task_InstanceHandling_Tests_Util.startDate
    let endDate = Task_InstanceHandling_Tests_Util.endDate
    let globalDowDates = Task_InstanceHandling_Tests_Util.globalDowDates
    let globalWomDates = Task_InstanceHandling_Tests_Util.globalWomDates
    let globalDomDates = Task_InstanceHandling_Tests_Util.globalDomDates
    
    var task: Task!
    
    override func setUpWithError() throws {
        task = Task_InstanceHandling_Tests_Util.setUp()
    }
    
    override func tearDownWithError() throws {
        Task_InstanceHandling_Tests_Util.tearDown()
    }

}

// MARK: - updateRecurringInstances performance tests

extension Task_InstanceHandling_Tests_Performance {
    
    // MARK: - Date change tests
    
    func testPerformance_updateRecurringInstances_performance_oneYearToFiveYears() {
        let newEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        }
    }
    
    func testPerformance_updateRecurringInstances_performance_oneYearToTenYears() {
        let newEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        }
    }
    
    func testPerformance_updateRecurringInstances_performance_fiveYearsToTenYears() {
        var newEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        
        newEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        }
    }
    
    func testPerformance_updateRecurringInstances_performance_fiveYearsToTwentyFiveYears() {
        var newEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        
        newEnd = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        }
    }
    
    func testPerformance_updateRecurringInstances_performance_tenYearsToTwentyFiveYears() {
        var newEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        
        newEnd = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        self.measure {
            task.updateRecurringInstances(startDate: startDate, endDate: newEnd)
        }
    }
    
    // MARK: - TTS deletion tests
    
    func testPerformance_updateRecurringInstances_performance_fiveYears_twoTTS() {
        
        let newStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let newEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: newStart, endDate: newEnd, targetSets: newTargetSets)
        }
        
    }
    
    func testPerformance_updateRecurringInstances_performance_tenYears_twoTTS() {
        
        let newStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let newEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 1, day: 1))!
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: newStart, endDate: newEnd, targetSets: newTargetSets)
        }
        
    }
    
    func testPerformance_updateRecurringInstances_performance_twentyFiveYears_twoTTS() {
        
        let newStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let newEnd = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        
        let newTargetSets = Set(arrayLiteral: getWomTargetSet(CDCoordinator.moc),getDomTargetSet(CDCoordinator.moc))
        self.measure {
            task.updateRecurringInstances(startDate: newStart, endDate: newEnd, targetSets: newTargetSets)
        }
        
    }
    
    /**
     Test updateRecurringInstances with 3 TTSes and every day selected in the dom TTS
     */
    func testPerformance_updateRecurringInstances_performance_twentyFiveYears_threeTTS_fullDom() {
        
        let newStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let newEnd = Calendar.current.date(from: DateComponents(year: 2045, month: 1, day: 1))!
        
        let newDomSet = TaskTargetSet(entity: TaskTargetSet.getEntityDescription(CDCoordinator.moc)!,
                                      insertInto: CDCoordinator.moc,
                                      min: 0, max: 1, minOperator: .lt, maxOperator: .lt, priority: 9,
                                      pattern: DayPattern(dow: Set<SaveFormatter.dayOfWeek>(),
                                                          wom: Set<SaveFormatter.weekOfMonth>(),
                                                          dom: Set<SaveFormatter.dayOfMonth>([.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten,
                                                                                              .eleven, .twelve, .thirteen, .fourteen, .fifteen, .sixteen, .seventeen, .eighteen, .nineteen, .twenty,
                                                                                              .twenty_one, .twenty_two, .twenty_three, .twenty_four, .twenty_five, .twenty_six, .twenty_seven, .twenty_eight, .twenty_nine, .thirty,
                                                                                              .thirty_one])))
        let newTargetSets: Set<TaskTargetSet> = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc), getWomTargetSet(CDCoordinator.moc), newDomSet)
        
        self.measure {
            task.updateRecurringInstances(startDate: newStart, endDate: newEnd, targetSets: newTargetSets)
        }
        
    }
    
}
