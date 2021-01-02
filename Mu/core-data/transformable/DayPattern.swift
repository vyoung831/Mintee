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
        coder.encode(NSSet(set: self.daysOfWeek), forKey: DayPattern.Keys.daysOfWeek.rawValue)
        coder.encode(NSSet(set: self.weeksOfMonth), forKey: DayPattern.Keys.weeksOfMonth.rawValue)
        coder.encode(NSSet(set: self.daysOfMonth), forKey: DayPattern.Keys.daysOfMonth.rawValue)
        coder.encode(self.type.rawValue, forKey: DayPattern.Keys.type.rawValue)
    }
    
    required init(coder decoder: NSCoder) {
        
        guard let dow = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfWeek.rawValue) as? Set<Int16>,
              let wom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.weeksOfMonth.rawValue) as? Set<Int16>,
              let dom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfMonth.rawValue) as? Set<Int16>,
              let typeValue = decoder.decodeObject(of: [DayPattern.self], forKey: DayPattern.Keys.type.rawValue) as? Int8 else {
            Crashlytics.crashlytics().log("Could not decode DayPattern")
            fatalError()
        }
        
        // Exit if the decoded type cannot be converted back into an enum value of type DayPattern.patternType
        if let type = patternType(rawValue: typeValue) {
            self.type = type
        } else {
            Crashlytics.crashlytics().log("DayPattern decoded an Int8 saved to type that could not be converted to a value of type patternType")
            Crashlytics.crashlytics().setCustomValue(typeValue, forKey: "Saved type raw value")
            fatalError()
        }
        
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        super.init()
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
