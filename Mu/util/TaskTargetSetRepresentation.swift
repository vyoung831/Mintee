//
//  TaskTargetSetRepresentation.swift
//  Mu
//
//  Created by Vincent Young on 5/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

struct TaskTargetSetRepresentation {
    
    enum TargetSetType {
        case dow // Day of week
        case wom // Weekday of month
        case dom // Day of month
    }
    
    var daysOfWeek: Set<Int>
    var weeksOfMonth: Set<Int>
    var daysOfMonth: Set<Int>
    var type: TargetSetType
    
    init(daysOfWeek: Set<Int16>, weeksOfMonth: Set<Int16>, daysOfMonth: Set<Int16>) {
        self.daysOfWeek = Set(daysOfWeek.map{Int($0)})
        self.weeksOfMonth = Set(weeksOfMonth.map{Int($0)})
        self.daysOfMonth = Set(daysOfMonth.map{Int($0)})
        if daysOfWeek.count > 0 {
            if weeksOfMonth.count > 0 { self.type = .wom }
            else { self.type = .dow }
        } else { self.type = .dom }
    }
    
    // MARK: - Date checking functions
    
    func checkDayOfWeek(weekday: Int) -> Bool {
        return daysOfWeek.contains(weekday)
    }
    
    func checkWeekdayOfMonth(day: Int, weekday: Int) -> Bool {
        return daysOfWeek.contains(weekday) &&
            weeksOfMonth.contains( Int( ceil( Float(day)/7 )) )
    }
    
    func checkDayOfMonth(day: Int) -> Bool {
        return daysOfMonth.contains(day)
    }
    
}
