//
//  EditTaskHostingController-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
@testable import SharedTestUtils
import CoreData
import XCTest

class EditTaskHostingController_Tests: XCTestCase {
    
    let dowMin: Float = 1, dowMax: Float = 2
    
    let daysOfWeek: Set<SaveFormatter.dayOfWeek> = Set(arrayLiteral: .sunday, .monday, .tuesday, .friday)
    func getDowTargetSet(_ moc: NSManagedObjectContext) throws -> TaskTargetSet {
        let dowPattern = DayPattern(dow: daysOfWeek, wom: Set<SaveFormatter.weekOfMonth>(), dom: Set<SaveFormatter.dayOfMonth>())
        return try TaskTargetSet(entity: TaskTargetSet.entity(),
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
    
}

// MARK:- EditTaskHostingController functions

extension EditTaskHostingController_Tests {
    
    func test_extractTTSVArray() throws {
        
        let targetSets: Set<TaskTargetSet> = Set(arrayLiteral: try getDowTargetSet(CDCoordinator.moc))
        let task = try Task(entity: Task.entity(),
                            insertInto: CDCoordinator.moc,
                            name: "Name",
                            tags: Set<Tag>([try Tag.getOrCreateTag(tagName: "Tag1")]),
                            startDate: Date(),
                            endDate: Date(),
                            targetSets: targetSets)
        
        let ttsvArray = try EditTaskHostingController.extractTTSVArray(task: task)
        let ttsv = ttsvArray[0]
        
        XCTAssert(ttsv.minTarget == dowMin)
        XCTAssert(ttsv.minOperator == .lt)
        XCTAssert(ttsv.maxTarget == dowMax)
        XCTAssert(ttsv.maxOperator == .lt)
        XCTAssert(ttsv.type == .dow)
        
        XCTAssert(daysOfWeek.count == ttsv.selectedDaysOfWeek!.count)
        for dayOfWeek in daysOfWeek {
            XCTAssert(ttsv.selectedDaysOfWeek!.contains(dayOfWeek))
        }
        
        XCTAssert(ttsv.selectedWeeksOfMonth!.count == 0)
        XCTAssert(ttsv.selectedDaysOfMonth!.count == 0)
        
    }
    
}
