//
//  EditTaskHostingController-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 9/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import CoreData
import XCTest

class EditTaskHostingController_Tests: XCTestCase {
    
    let dowMin: Float = 1, dowMax: Float = 2
    
    let daysOfWeek: Set<Int16> = Set(arrayLiteral: 1,2,3,6)
    func getDowTargetSet(_ moc: NSManagedObjectContext) -> TaskTargetSet {
        let dowPattern = DayPattern(dow: daysOfWeek, wom: Set<Int16>(), dom: Set<Int16>())
        return TaskTargetSet(entity: TaskTargetSet.getEntityDescription(moc)!,
                             insertInto: moc,
                             min: dowMin, max: dowMax,
                             minOperator: .lt, maxOperator: .lt,
                             priority: 3,
                             pattern: dowPattern)
    }
    
    override func setUpWithError() throws {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    override func tearDownWithError() throws {
        CDCoordinator.moc.rollback()
    }
    
    func test_extractTTSVArray() throws {
        
        let targetSets: Set<TaskTargetSet> = Set(arrayLiteral: getDowTargetSet(CDCoordinator.moc))
        let task = Task(entity: Task.getEntityDescription(CDCoordinator.moc)!,
                        insertInto: CDCoordinator.moc,
                        name: "Name",
                        tags: Set<Tag>([Tag.getOrCreateTag(tagName: "Tag1")!]),
                        startDate: Date(),
                        endDate: Date(),
                        targetSets: targetSets)
        
        let ttsvArray = EditTaskHostingController.extractTTSVArray(task: task)
        let ttsv = ttsvArray![0]
        
        XCTAssert(ttsv.minTarget == dowMin)
        XCTAssert(ttsv.minOperator == .lt)
        XCTAssert(ttsv.maxTarget == dowMax)
        XCTAssert(ttsv.maxOperator == .lt)
        XCTAssert(ttsv.type == .dow)
        
        XCTAssert(daysOfWeek.count == ttsv.selectedDaysOfWeek!.count)
        for dayOfWeek in daysOfWeek {
            XCTAssert(ttsv.selectedDaysOfWeek!.contains(SaveFormatter.getWeekdayString(weekday: dayOfWeek)))
        }
        
        XCTAssert(ttsv.selectedWeeksOfMonth!.count == 0)
        XCTAssert(ttsv.selectedDaysOfMonth!.count == 0)
        
    }
    
}
