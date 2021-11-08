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
    
    enum patternType: Int8, CaseIterable {
        case dow = 1
        case wom = 2
        case dom = 3
    }
    
    static var supportsSecureCoding: Bool = true
    private var daysOfWeek: Set<Int16>
    private var weeksOfMonth: Set<Int16>
    private var daysOfMonth: Set<Int16>
    private var type: Int8
    
    var _type: DayPattern.patternType {
        get throws {
            guard let castType = DayPattern.patternType.init(rawValue: self.type) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                  ["type": self.type])
            }
            return castType
        }
    }
    
    var _daysOfWeek: Set<SaveFormatter.dayOfWeek> {
        get throws {
            let castDow: [SaveFormatter.dayOfWeek] = try self.daysOfWeek.map{
                guard let decodedDow = SaveFormatter.dayOfWeek.init(rawValue: $0) else {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                      ["daysOfWeek": self.daysOfWeek.debugDescription])
                }
                return decodedDow
            }
            return Set(castDow)
        }
    }
    
    var _weeksOfMonth: Set<SaveFormatter.weekOfMonth> {
        get throws {
            let castWom: [SaveFormatter.weekOfMonth] = try self.weeksOfMonth.map{
                guard let decodedWom = SaveFormatter.weekOfMonth.init(rawValue: $0) else {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                      ["weeksOfMonth": self.weeksOfMonth.debugDescription])
                }
                return decodedWom
            }
            return Set(castWom)
        }
    }
    
    var _daysOfMonth: Set<SaveFormatter.dayOfMonth> {
        get throws {
            let castDom: [SaveFormatter.dayOfMonth] = try self.daysOfMonth.map{
                guard let decodedDom = SaveFormatter.dayOfMonth.init(rawValue: $0) else {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                      ["daysOfMonth": self.daysOfMonth.debugDescription])
                }
                return decodedDom
            }
            return Set(castDom)
        }
    }
    
    init(dow: Set<SaveFormatter.dayOfWeek>, wom: Set<SaveFormatter.weekOfMonth>, dom: Set<SaveFormatter.dayOfMonth>) {
        self.daysOfWeek = Set(dow.map{$0.rawValue})
        self.weeksOfMonth = Set(wom.map{$0.rawValue})
        self.daysOfMonth = Set(dom.map{$0.rawValue})
        if dom.count > 0 {
            self.type = DayPattern.patternType.dom.rawValue
        } else {
            if wom.count > 0 { self.type = DayPattern.patternType.wom.rawValue }
            else { self.type = DayPattern.patternType.dow.rawValue }
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSSet(set: self.daysOfWeek), forKey: DayPattern.Keys.daysOfWeek.rawValue)
        coder.encode(NSSet(set: self.weeksOfMonth), forKey: DayPattern.Keys.weeksOfMonth.rawValue)
        coder.encode(NSSet(set: self.daysOfMonth), forKey: DayPattern.Keys.daysOfMonth.rawValue)
        coder.encode(NSNumber(value: self.type), forKey: DayPattern.Keys.type.rawValue)
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
        
        self.type = typeValue
        self.daysOfWeek = dow
        self.weeksOfMonth = wom
        self.daysOfMonth = dom
        super.init()
    }
    
}

// MARK: - Helper functions

extension DayPattern {
    
    func check_dayOfWeek(_ date: Date) -> Bool {
        let dowComponent = Int16(Calendar.current.component(.weekday, from: date))
        return self.daysOfWeek.contains(dowComponent)
    }
    
    func check_weekOfMonth(_ date: Date,_ weekOfMonth: Int16? = nil) -> Bool {
        let womComponent = weekOfMonth ?? Int16(Calendar.current.component(.weekOfMonth, from: date))
        return self.weeksOfMonth.contains(womComponent)
    }
    
    func check_dayOfMonth(_ date: Date) -> Bool {
        let domComponent = Int16(Calendar.current.component(.day, from: date))
        return self.daysOfMonth.contains(domComponent)
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
        userInfo["\(prefix)daysOfWeek"] = self.daysOfWeek.debugDescription
        userInfo["\(prefix)weeksOfMonth"] = self.weeksOfMonth.debugDescription
        userInfo["\(prefix)daysOfMonth"] = self.daysOfMonth.debugDescription
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
