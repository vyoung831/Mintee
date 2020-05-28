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
    
    /**
     - returns: A Set of Int16, representing the day value of each DayOfWeek in this object's daysOfWeek relationship
     */
    func getDaysOfWeek() -> Set<Int16> {
        if let dows = self.daysOfWeek?.allObjects as? [DayOfWeek] {
            return Set(dows.map{ $0.day })
        }
        return []
    }
    
    /**
    - returns: A Set of Int16, representing the week value of each WeekOfMonth in this object's weeksOfMonth relationship
    */
    func getWeeksOfMonth() -> Set<Int16> {
        if let woms = self.weeksOfMonth?.allObjects as? [WeekOfMonth] {
            return Set(woms.map{ $0.week })
        }
        return []
    }
    
    /**
    - returns: A Set of Int16, representing the day value of each DayOfMonth in this object's daysOfMonth relationship
    */
    func getDaysOfMonth() -> Set<Int16> {
        if let doms = self.daysOfMonth?.allObjects as? [DayOfMonth] {
            return Set(doms.map{ $0.day })
        }
        return []
    }
    
}
