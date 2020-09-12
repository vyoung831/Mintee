//
//  TaskTargetSet+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 5/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TaskTargetSet)
public class TaskTargetSet: NSManagedObject {
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext?,
                     min: Float,
                     max: Float,
                     minOperator: Int16,
                     maxOperator: Int16,
                     priority: Int16,
                     pattern: DayPattern) {
        self.init(entity: entity, insertInto: context)
        self.min = min
        self.max = max
        self.minOperator = minOperator
        self.maxOperator = maxOperator
        self.priority = priority
        self.pattern = pattern
    }
    
    /**
     Checks this object's DayPattern to determine if it intersects with the provided day/weekday combo
     - parameter day: day of month to check
     - parameter weekday: weekday to check; should have been obtained from a Calendar's weekday component
     - returns: True if parameters matched with this TaskTargetSet's pattern
     */
    func checkDay(day: Int16, weekday: Int16, daysInMonth: Int16) -> Bool {
        
        guard let pattern = self.pattern as? DayPattern else {
            print("TaskTargetSet \(self.description) was unable to retrieve its DayPattern"); exit(-1)
        }
        
        if daysInMonth < 28 {
            print("checkDay() in TaskTargetSet received an invalid number of daysInMonth: \(daysInMonth)"); exit(-1)
        }
        
        switch pattern.type {
        case .dow:
            return pattern.daysOfWeek.contains(weekday)
        case .wom:
            if pattern.weeksOfMonth.contains(SaveFormatter.getWeekOfMonthNumber(wom: "Last")) {
                return pattern.daysOfWeek.contains(weekday) &&
                    (pattern.weeksOfMonth.contains( Int16( ceil( Float(day)/7 )) ) || day + 7 > daysInMonth)
            }
            return pattern.daysOfWeek.contains(weekday) &&
                (pattern.weeksOfMonth.contains( Int16( ceil( Float(day)/7 )) ))
        case .dom:
            /*
             Last day of month is represented as 0, so the following conditions are checked
             - The DayPattern's selected days of month are checked for equality to dateCounter's day, OR
             - The DayPattern's selected days of month contains 0 and dateCounter is the last day of the month
             */
            return pattern.daysOfMonth.contains(day) || ( pattern.daysOfMonth.contains(0) && day == daysInMonth)
        }
        
    }
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfWeek in this object's daysOfWeek relationship
     */
    func getDaysOfWeek() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            print("TaskTargetSet \(self.description) was unable to retrieve its DayPattern")
            exit(-1)
        }
        return Set(pattern.daysOfWeek)
    }
    
    /**
     - returns: A Set of Int16, representing the week value of each WeekOfMonth in this object's weeksOfMonth relationship
     */
    func getWeeksOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            print("TaskTargetSet \(self.description) was unable to retrieve its DayPattern")
            exit(-1)
        }
        return Set(pattern.weeksOfMonth)
    }
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfMonth in this object's daysOfMonth relationship
     */
    func getDaysOfMonth() -> Set<Int16> {
        guard let pattern = self.pattern as? DayPattern else {
            print("TaskTargetSet \(self.description) was unable to retrieve its DayPattern")
            exit(-1)
        }
        return Set(pattern.daysOfMonth)
    }
    
}
