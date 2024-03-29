//
//  Task-InstanceHandling-Tests-Util.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mintee
import Foundation
import CoreData

public class Task_InstanceHandling_Tests_Util {
    
    public static func setUp() throws -> Task {
        return try Task(entity: Task.entity(),
                        insertInto: CDCoordinator.moc,
                        name: "Task", tags: [],
                        startDate: startDate, endDate: endDate,
                        targetSets: [getDowTargetSet(CDCoordinator.moc),
                                     getWomTargetSet(CDCoordinator.moc),
                                     getDomTargetSet(CDCoordinator.moc)])
    }
    
}

extension Task_InstanceHandling_Tests_Util {
    
    public static let dowMin: Float = 1, dowMax: Float = 2, womMin: Float = 3, womMax: Float = 4, domMin: Float = 5, domMax: Float = 6
    
    public static func getDowTargetSet(_ moc: NSManagedObjectContext) throws -> TaskTargetSet {
        let dowPattern = DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.sunday, .monday, .tuesday, .friday]),
                                    wom: Set<SaveFormatter.weekOfMonth>(),
                                    dom: Set<SaveFormatter.dayOfMonth>())
        return try TaskTargetSet(entity: TaskTargetSet.entity(),
                                 insertInto: moc,
                                 min: dowMin, max: dowMax,
                                 minOperator: .lt, maxOperator: .lt,
                                 priority: 3,
                                 pattern: dowPattern)
    }
    
    public static func getWomTargetSet(_ moc: NSManagedObjectContext) throws -> TaskTargetSet {
        let womPattern = DayPattern(dow: Set<SaveFormatter.dayOfWeek>([.monday, .wednesday]),
                                    wom: Set<SaveFormatter.weekOfMonth>([.first, .third, .last]),
                                    dom: Set<SaveFormatter.dayOfMonth>())
        return try TaskTargetSet(entity: TaskTargetSet.entity(),
                                 insertInto: moc,
                                 min: womMin, max: womMax,
                                 minOperator: .lt, maxOperator: .lt,
                                 priority: 6,
                                 pattern: womPattern)
    }
    
    public static func getDomTargetSet(_ moc: NSManagedObjectContext) throws -> TaskTargetSet {
        let domPattern = DayPattern(dow: Set<SaveFormatter.dayOfWeek>(),
                                    wom: Set<SaveFormatter.weekOfMonth>(),
                                    dom: Set<SaveFormatter.dayOfMonth>([.last, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten]))
        return try TaskTargetSet(entity: TaskTargetSet.entity(),
                                 insertInto: moc,
                                 min: domMin, max: domMax,
                                 minOperator: .lt, maxOperator: .lt,
                                 priority: 9,
                                 pattern: domPattern)
    }
    
    /*
     Dates from Jan 1, 2020 to Jan 1, 2021 and String representations of dates that each TaskTargetSet applies to
     */
    public static let startDate = Calendar.current.date(from: DateComponents(year: 2019, month: 11, day: 1))!
    public static let endDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
    public static let globalDowDates: Set<String> =  Set(["2019-11-01", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-08", "2019-11-10", "2019-11-11", "2019-11-12", "2019-11-15", "2019-11-17", "2019-11-18", "2019-11-19", "2019-11-22", "2019-11-24", "2019-11-25", "2019-11-26", "2019-11-29", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-06", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-13", "2019-12-15", "2019-12-16", "2019-12-17", "2019-12-20", "2019-12-22", "2019-12-23", "2019-12-24", "2019-12-27", "2019-12-29", "2019-12-30", "2019-12-31", "2020-01-03", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-10", "2020-01-12", "2020-01-13", "2020-01-14", "2020-01-17", "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-24", "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-31", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-07", "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-14", "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-21", "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-28", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-06", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-13", "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-20", "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-27", "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-03", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-10", "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-17", "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-24", "2020-04-26", "2020-04-27", "2020-04-28", "2020-05-01", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-08", "2020-05-10", "2020-05-11", "2020-05-12", "2020-05-15", "2020-05-17", "2020-05-18", "2020-05-19", "2020-05-22", "2020-05-24", "2020-05-25", "2020-05-26", "2020-05-29", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-05", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-12", "2020-06-14", "2020-06-15", "2020-06-16", "2020-06-19", "2020-06-21", "2020-06-22", "2020-06-23", "2020-06-26", "2020-06-28", "2020-06-29", "2020-06-30", "2020-07-03", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-10", "2020-07-12", "2020-07-13", "2020-07-14", "2020-07-17", "2020-07-19", "2020-07-20", "2020-07-21", "2020-07-24", "2020-07-26", "2020-07-27", "2020-07-28", "2020-07-31", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-07", "2020-08-09", "2020-08-10", "2020-08-11", "2020-08-14", "2020-08-16", "2020-08-17", "2020-08-18", "2020-08-21", "2020-08-23", "2020-08-24", "2020-08-25", "2020-08-28", "2020-08-30", "2020-08-31", "2020-09-01", "2020-09-04", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-11", "2020-09-13", "2020-09-14", "2020-09-15", "2020-09-18", "2020-09-20", "2020-09-21", "2020-09-22", "2020-09-25", "2020-09-27", "2020-09-28", "2020-09-29", "2020-10-02", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-09", "2020-10-11", "2020-10-12", "2020-10-13", "2020-10-16", "2020-10-18", "2020-10-19", "2020-10-20", "2020-10-23", "2020-10-25", "2020-10-26", "2020-10-27", "2020-10-30", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-06", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-13", "2020-11-15", "2020-11-16", "2020-11-17", "2020-11-20", "2020-11-22", "2020-11-23", "2020-11-24", "2020-11-27", "2020-11-29", "2020-11-30", "2020-12-01", "2020-12-04", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-11", "2020-12-13", "2020-12-14", "2020-12-15", "2020-12-18", "2020-12-20", "2020-12-21", "2020-12-22", "2020-12-25", "2020-12-27", "2020-12-28", "2020-12-29", "2021-01-01", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-08", "2021-01-10", "2021-01-11", "2021-01-12", "2021-01-15", "2021-01-17", "2021-01-18", "2021-01-19", "2021-01-22", "2021-01-24", "2021-01-25", "2021-01-26", "2021-01-29", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-05", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-12", "2021-02-14", "2021-02-15", "2021-02-16", "2021-02-19", "2021-02-21", "2021-02-22", "2021-02-23", "2021-02-26", "2021-02-28", "2021-03-01"])
    public static let globalWomDates: Set<String> = Set(["2019-11-04", "2019-11-06", "2019-11-18", "2019-11-20", "2019-11-25", "2019-11-27", "2019-12-02", "2019-12-04", "2019-12-16", "2019-12-18", "2019-12-25", "2019-12-30", "2020-01-01", "2020-01-06", "2020-01-15", "2020-01-20", "2020-01-27", "2020-01-29", "2020-02-03", "2020-02-05", "2020-02-17", "2020-02-19", "2020-02-24", "2020-02-26", "2020-03-02", "2020-03-04", "2020-03-16", "2020-03-18", "2020-03-25", "2020-03-30", "2020-04-01", "2020-04-06", "2020-04-15", "2020-04-20", "2020-04-27", "2020-04-29", "2020-05-04", "2020-05-06", "2020-05-18", "2020-05-20", "2020-05-25", "2020-05-27", "2020-06-01", "2020-06-03", "2020-06-15", "2020-06-17", "2020-06-24", "2020-06-29", "2020-07-01", "2020-07-06", "2020-07-15", "2020-07-20", "2020-07-27", "2020-07-29", "2020-08-03", "2020-08-05", "2020-08-17", "2020-08-19", "2020-08-26", "2020-08-31", "2020-09-02", "2020-09-07", "2020-09-16", "2020-09-21", "2020-09-28", "2020-09-30", "2020-10-05", "2020-10-07", "2020-10-19", "2020-10-21", "2020-10-26", "2020-10-28", "2020-11-02", "2020-11-04", "2020-11-16", "2020-11-18", "2020-11-25", "2020-11-30", "2020-12-02", "2020-12-07", "2020-12-16", "2020-12-21", "2020-12-28", "2020-12-30", "2021-01-04", "2021-01-06", "2021-01-18", "2021-01-20", "2021-01-25", "2021-01-27", "2021-02-01", "2021-02-03", "2021-02-15", "2021-02-17", "2021-02-22", "2021-02-24", "2021-03-01"])
    public static let globalDomDates: Set<String> = Set(["2019-11-01", "2019-11-02", "2019-11-03", "2019-11-04", "2019-11-05", "2019-11-06", "2019-11-07", "2019-11-08", "2019-11-09", "2019-11-10", "2019-11-30", "2019-12-01", "2019-12-02", "2019-12-03", "2019-12-04", "2019-12-05", "2019-12-06", "2019-12-07", "2019-12-08", "2019-12-09", "2019-12-10", "2019-12-31", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06", "2020-01-07", "2020-01-08", "2020-01-09", "2020-01-10", "2020-01-31", "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10", "2020-02-29", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-31", "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10", "2020-04-30", "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09", "2020-05-10", "2020-05-31", "2020-06-01", "2020-06-02", "2020-06-03", "2020-06-04", "2020-06-05", "2020-06-06", "2020-06-07", "2020-06-08", "2020-06-09", "2020-06-10", "2020-06-30", "2020-07-01", "2020-07-02", "2020-07-03", "2020-07-04", "2020-07-05", "2020-07-06", "2020-07-07", "2020-07-08", "2020-07-09", "2020-07-10", "2020-07-31", "2020-08-01", "2020-08-02", "2020-08-03", "2020-08-04", "2020-08-05", "2020-08-06", "2020-08-07", "2020-08-08", "2020-08-09", "2020-08-10", "2020-08-31", "2020-09-01", "2020-09-02", "2020-09-03", "2020-09-04", "2020-09-05", "2020-09-06", "2020-09-07", "2020-09-08", "2020-09-09", "2020-09-10", "2020-09-30", "2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04", "2020-10-05", "2020-10-06", "2020-10-07", "2020-10-08", "2020-10-09", "2020-10-10", "2020-10-31", "2020-11-01", "2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06", "2020-11-07", "2020-11-08", "2020-11-09", "2020-11-10", "2020-11-30", "2020-12-01", "2020-12-02", "2020-12-03", "2020-12-04", "2020-12-05", "2020-12-06", "2020-12-07", "2020-12-08", "2020-12-09", "2020-12-10", "2020-12-31", "2021-01-01", "2021-01-02", "2021-01-03", "2021-01-04", "2021-01-05", "2021-01-06", "2021-01-07", "2021-01-08", "2021-01-09", "2021-01-10", "2021-01-31", "2021-02-01", "2021-02-02", "2021-02-03", "2021-02-04", "2021-02-05", "2021-02-06", "2021-02-07", "2021-02-08", "2021-02-09", "2021-02-10", "2021-02-28", "2021-03-01"])
    
}
