//
//  DayPattern.swift
//  Mu
//
//  Created by Vincent Young on 5/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

class DayPattern: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    enum patternType: Int8 {
        case dow = 1
        case wom = 2
        case dom = 3
    }
    
    var daysOfWeek: [Int]
    var weeksOfMonth: [Int]
    var daysOfMonth: [Int]
    var type: patternType
    
    init(dow: [Int], wom: [Int], dom: [Int]) {
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
        guard let dow = decoder.decodeObject(of: [DayPattern.self], forKey: "daysOfWeek") as? [Int],
            let wom = decoder.decodeObject(of: [DayPattern.self], forKey: "weeksOfMonth") as? [Int],
            let dom = decoder.decodeObject(of: [DayPattern.self], forKey: "daysOfMonth") as? [Int],
            let typeValue = decoder.decodeObject(of: [DayPattern.self], forKey: "type") as? Int8
            else {
            exit(-1)
        }
        
        // Exit if the decoded type cannot be converted back into an enum value of type DayPattern.patternType
        if let type = patternType(rawValue: typeValue) {
            self.type = type
        } else {
            exit(-1)
        }
        
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        super.init()
    }
    
}
