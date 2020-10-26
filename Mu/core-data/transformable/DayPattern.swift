//
//  DayPattern.swift
//  Mu
//
//  Created by Vincent Young on 5/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class DayPattern: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    enum patternType: Int8, CaseIterable {
        case dow = 1
        case wom = 2
        case dom = 3
    }
    
    var daysOfWeek: Set<Int16>
    var weeksOfMonth: Set<Int16>
    var daysOfMonth: Set<Int16>
    var type: patternType
    
    init(dow: Set<Int16>, wom: Set<Int16>, dom: Set<Int16>) {
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        if dom.count > 0 { self.type = .dom } else {
            if wom.count > 0 { self.type = .wom }
            else { self.type = .dow }
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.daysOfWeek, forKey: "daysOfWeek")
        coder.encode(self.weeksOfMonth, forKey: "weeksOfMonth")
        coder.encode(self.daysOfMonth, forKey: "daysOfMonth")
        coder.encode(self.type.rawValue, forKey: "type")
    }
    
    required init(coder decoder: NSCoder) {
        guard let dow = decoder.decodeObject(of: [DayPattern.self], forKey: "daysOfWeek") as? Set<Int16>,
            let wom = decoder.decodeObject(of: [DayPattern.self], forKey: "weeksOfMonth") as? Set<Int16>,
            let dom = decoder.decodeObject(of: [DayPattern.self], forKey: "daysOfMonth") as? Set<Int16>,
            let typeValue = decoder.decodeObject(of: [DayPattern.self], forKey: "type") as? Int8 else {
            Crashlytics.crashlytics().log("Could not decode DayPattern")
            fatalError()
        }
        
        // Exit if the decoded type cannot be converted back into an enum value of type DayPattern.patternType
        if let type = patternType(rawValue: typeValue) {
            self.type = type
        } else {
            Crashlytics.crashlytics().log("DayPattern decoded an Int8 saved to type that could not be converted to a value of type patternType")
            Crashlytics.crashlytics().setValue(typeValue, forKey: "Saved type raw value")
            fatalError()
        }
        
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        super.init()
    }
    
}
