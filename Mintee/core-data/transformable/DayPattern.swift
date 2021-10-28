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
    
    var daysOfWeek: Set<SaveFormatter.dayOfWeek>
    var weeksOfMonth: Set<SaveFormatter.weekOfMonth>
    var daysOfMonth: Set<SaveFormatter.dayOfMonth>
    var type: DayPattern.patternType
    
    init(dow: Set<SaveFormatter.dayOfWeek>, wom: Set<SaveFormatter.weekOfMonth>, dom: Set<SaveFormatter.dayOfMonth>) {
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        if dom.count > 0 { self.type = .dom } else {
            if wom.count > 0 { self.type = .wom }
            else { self.type = .dow }
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSSet(set: Set(self.daysOfWeek.map{ $0.rawValue })), forKey: DayPattern.Keys.daysOfWeek.rawValue)
        coder.encode(NSSet(set: Set(self.weeksOfMonth.map{ $0.rawValue })), forKey: DayPattern.Keys.weeksOfMonth.rawValue)
        coder.encode(NSSet(set: Set(self.daysOfMonth.map{ $0.rawValue })), forKey: DayPattern.Keys.daysOfMonth.rawValue)
        coder.encode(NSNumber(value: self.type.rawValue), forKey: DayPattern.Keys.type.rawValue)
    }
    
    required init?(coder decoder: NSCoder) {
        
        guard let dow = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfWeek.rawValue) as? Set<Int16>,
              let wom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.weeksOfMonth.rawValue) as? Set<Int16>,
              let dom = decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfMonth.rawValue) as? Set<Int16>,
              let typeValue = decoder.decodeObject(of: NSNumber.self, forKey: DayPattern.Keys.type.rawValue) as? Int8 else {
                  let userInfo: [String : Any] =
                  [DayPattern.Keys.daysOfWeek.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfWeek.rawValue).debugDescription,
                   DayPattern.Keys.weeksOfMonth.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.weeksOfMonth.rawValue).debugDescription,
                   DayPattern.Keys.daysOfMonth.rawValue : decoder.decodeObject(of: NSSet.self, forKey: DayPattern.Keys.daysOfMonth.rawValue).debugDescription,
                   DayPattern.Keys.type.rawValue : decoder.decodeObject(of: NSNumber.self, forKey: DayPattern.Keys.type.rawValue).debugDescription]
                  let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, userInfo)
                  return nil
              }
        
        // Exit if the decoded type cannot be converted back into an enum value of type DayPattern.patternType
        guard let type = patternType(rawValue: typeValue) else {
            let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, ["decoded value" : typeValue])
            return nil
        }
        
        var finalDow: Set<SaveFormatter.dayOfWeek> = Set()
        var finalWom: Set<SaveFormatter.weekOfMonth> = Set()
        var finalDom: Set<SaveFormatter.dayOfMonth> = Set()
        for dayOfWeek in dow {
            guard let decodedDow = SaveFormatter.dayOfWeek.init(rawValue: dayOfWeek) else {
                let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, ["dayOfWeek": dayOfWeek]); return nil
            }
            finalDow.insert(decodedDow)
        }
        for weekOfMonth in wom {
            guard let decodedWom = SaveFormatter.weekOfMonth.init(rawValue: weekOfMonth) else {
                let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, ["weekOfMonth": weekOfMonth]); return nil
            }
            finalWom.insert(decodedWom)
        }
        for dayOfMonth in dom {
            guard let decodedDom = SaveFormatter.dayOfMonth.init(rawValue: dayOfMonth) else {
                let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, ["dayOfMonth": dayOfMonth]); return nil
            }
            finalDom.insert(decodedDom)
        }
        
        self.type = type
        self.daysOfWeek = finalDow
        self.weeksOfMonth = finalWom
        self.daysOfMonth = finalDom
        super.init()
    }
    
}

// MARK: - Helper functions

extension DayPattern {
    
    func check_dayOfWeek(_ date: Date) throws -> Bool {
        let dowComponent = Int16(Calendar.current.component(.weekday, from: date))
        guard let dow = SaveFormatter.dayOfWeek.init(rawValue: dowComponent) else {
            throw ErrorManager.recordNonFatal(.dateOperationFailed,
                                              ["dowComponent": dowComponent])
        }
        return self.daysOfWeek.contains(dow)
    }
    
    func check_weekOfMonth(_ date: Date,_ weekOfMonth: Int16? = nil) throws -> Bool {
        let womComponent = weekOfMonth ?? Int16(Calendar.current.component(.weekOfMonth, from: date))
        guard let wom = SaveFormatter.weekOfMonth.init(rawValue: womComponent) else {
            throw ErrorManager.recordNonFatal(.dateOperationFailed,
                                              ["womComponent": womComponent])
        }
        return self.weeksOfMonth.contains(wom)
    }
    
    func check_dayOfMonth(_ date: Date) throws -> Bool {
        let domComponent = Int16(Calendar.current.component(.day, from: date))
        guard let dom = SaveFormatter.dayOfMonth.init(rawValue: domComponent) else {
            throw ErrorManager.recordNonFatal(.dateOperationFailed,
                                              ["domComponent": domComponent])
        }
        return self.daysOfMonth.contains(dom)
    }
    
}

// MARK: - Debug reporting

extension DayPattern {
    
    /**
     Gathers debug descriptions of this DayPattern and its properties.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys that this function adds to `userInfo`.
     - returns: Dictionary containing existing debug info + debug descriptions of DayPattern
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        userInfo["\(prefix)daysOfWeek"] = self.daysOfWeek
        userInfo["\(prefix)weeksOfMonth"] = self.weeksOfMonth
        userInfo["\(prefix)daysOfMonth"] = self.daysOfMonth
        userInfo["\(prefix)type"] = self.type
    }
    
}

// MARK: - Unarchiving transformer

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
