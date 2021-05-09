//
//  DayPattern.swift
//  Mintee
//
//  Created by Vincent Young on 5/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class DayPattern: NSObject, NSSecureCoding {
    
    enum Keys: String {
        case daysOfWeek = "DaysOfWeek"
        case weeksOfMonth = "WeeksOfMonth"
        case daysOfMonth = "DaysOfMonth"
        case type = "Type"
    }
    
    static var supportsSecureCoding: Bool = true
    
    enum patternType: Int8, CaseIterable {
        case dow = 1
        case wom = 2
        case dom = 3
    }
    
    var daysOfWeek: Set<Int16>
    var weeksOfMonth: Set<Int16>
    var daysOfMonth: Set<Int16>
    var type: DayPattern.patternType
    
    init(dow: Set<SaveFormatter.dayOfWeek>,
         wom: Set<SaveFormatter.weekOfMonth>,
         dom: Set<SaveFormatter.dayOfMonth>) {
        
        self.daysOfWeek = Set( dow.map {
            SaveFormatter.dayOfWeekToStored($0)
        })
        self.weeksOfMonth = Set( wom.map{
            SaveFormatter.weekOfMonthToStored($0)
        })
        self.daysOfMonth = Set ( dom.map{
            SaveFormatter.dayOfMonthToStored($0)
        })
        
        if dom.count > 0 { self.type = .dom } else {
            if wom.count > 0 { self.type = .wom }
            else { self.type = .dow }
        }
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSSet(set: self.daysOfWeek), forKey: DayPattern.Keys.daysOfWeek.rawValue)
        coder.encode(NSSet(set: self.weeksOfMonth), forKey: DayPattern.Keys.weeksOfMonth.rawValue)
        coder.encode(NSSet(set: self.daysOfMonth), forKey: DayPattern.Keys.daysOfMonth.rawValue)
        coder.encode(NSNumber(value: self.type.rawValue), forKey: DayPattern.Keys.type.rawValue)
    }
    
    required init?(coder decoder: NSCoder) {
        
        guard let dow = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfWeek.rawValue) as? Set<Int16>,
              let wom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.weeksOfMonth.rawValue) as? Set<Int16>,
              let dom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfMonth.rawValue) as? Set<Int16>,
              let typeValue = decoder.decodeObject(of: NSNumber.self, forKey: DayPattern.Keys.type.rawValue) as? Int8 else {
            let userInfo: [String : Any] =
                ["Message" : "DayPattern.init() could not decode its properties",
                 DayPattern.Keys.daysOfWeek.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfWeek.rawValue).debugDescription,
                 DayPattern.Keys.weeksOfMonth.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.weeksOfMonth.rawValue).debugDescription,
                 DayPattern.Keys.daysOfMonth.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfMonth.rawValue).debugDescription,
                 DayPattern.Keys.type.rawValue : decoder.decodeObject(of: NSNumber.self, forKey: DayPattern.Keys.type.rawValue).debugDescription]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        
        // Exit if the decoded type cannot be converted back into an enum value of type DayPattern.patternType
        guard let type = patternType(rawValue: typeValue) else {
            let userInfo: [String : Any] = ["Message" : "DayPattern.init() could not initialize a value of type DayPattern.patternType from the saved Int8",
                                            "decoded value" : typeValue]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        
        self.type = type
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        super.init()
    }
    
}

extension DayPattern {
    
    /**
     Gathers debug descriptions of this DayPattern and its properties.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info
     - returns: Dictionary containing existing debug info + debug descriptions of DayPattern
     */
    func mergeDebugDictionary(userInfo: [String : Any]) -> [String : Any] {
        
        var debugDictionary: [String : Any] = [:]
        
        debugDictionary["DayPattern.daysOfWeek"] = self.daysOfWeek
        debugDictionary["DayPattern.weeksOfMonth"] = self.weeksOfMonth
        debugDictionary["DayPattern.daysOfMonth"] = self.daysOfMonth
        debugDictionary["DayPattern.type"] = self.type
        
        debugDictionary.merge(userInfo, uniquingKeysWith: {
            return "(Keys clashed).\nValue 1 = \($0)\nValue 2 = \($1)"
        })
        return debugDictionary
    }
    
}

// Subclass from `NSSecureUnarchiveFromDataTransformer`
@objc(DayPatternTransformer)
final class DayPatternTransformer: NSSecureUnarchiveFromDataTransformer {
    
    // The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: DayPatternTransformer.self))
    
    /**
     Registers the transformer.
     */
    public static func register() {
        let transformer = DayPatternTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
    
    public override static var allowedTopLevelClasses: [AnyClass] {
        return [DayPattern.self]
    }
    
}
