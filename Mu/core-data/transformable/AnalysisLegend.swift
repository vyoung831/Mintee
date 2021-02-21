//
//  AnalysisLegend.swift
//  Mu
//
//  Created by Vincent Young on 2/14/21.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import UIKit

class AnalysisLegend: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    enum Keys: String {
        case entries = "entries"
    }
    
    var entries: Set<LegendEntry>
    
    init(legendEntries: Set<LegendEntry>) {
        self.entries = legendEntries
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSSet(set: self.entries), forKey: AnalysisLegend.Keys.entries.rawValue)
    }
    
    required init?(coder decoder: NSCoder) {
        
        guard let legendEntries = decoder.decodeObject(of: [NSSet.self, LegendEntry.self], forKey: AnalysisLegend.Keys.entries.rawValue ) as? Set<LegendEntry> else {
            let userInfo: [String : Any] =
                ["Message" : "AnalysisLegend.init() could not decode its entries",
                 AnalysisLegend.Keys.entries.rawValue : decoder.decodeObject(of: [NSSet.self, LegendEntry.self], forKey: AnalysisLegend.Keys.entries.rawValue).debugDescription]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        self.entries = legendEntries
        
    }
    
    /**
     Gathers debug descriptions of this AnalysisLegend's LegendEntries and their properties.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info
     - returns: Dictionary containing existing debug info + debug descriptions of LegendEntries' properties
     */
    func mergeDebugDictionary(userInfo: [String : Any]) -> [String : Any] {
        
        var debugDictionary: [String : Any] = [:]
        
        var idx = 0;
        for entry in entries {
            debugDictionary["LegendEntry[\(idx)].color"] = entry.color.debugDescription
            debugDictionary["LegendEntry[\(idx)].min"] = entry.min.debugDescription
            debugDictionary["LegendEntry[\(idx)].max"] = entry.max.debugDescription
            debugDictionary["LegendEntry[\(idx)].minOperator"] = entry.minOperator
            debugDictionary["LegendEntry[\(idx)].maxOperator"] = entry.maxOperator
            idx += 1
        }
        
        debugDictionary.merge(userInfo, uniquingKeysWith: {
            return "(Keys clashed).\nValue 1 = \($0)\nValue 2 = \($1)"
        })
        return debugDictionary
    }
    
}

// Subclass from `NSSecureUnarchiveFromDataTransformer`
@objc(AnalysisLegendTransformer)
final class AnalysisLegendTransformer: NSSecureUnarchiveFromDataTransformer {
    
    // The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTransformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: AnalysisLegendTransformer.self))
    
    public static func register() {
        let transformer = AnalysisLegendTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
    
    public override static var allowedTopLevelClasses: [AnyClass] {
        return [AnalysisLegend.self]
    }
    
}

// MARK: - LegendEntry

class LegendEntry: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    enum Keys: String {
        case color = "color"
        case min = "min"
        case max = "max"
        case minOperator = "minOperator"
        case maxOperator = "maxOperator"
    }
    
    var color: String
    var min: Float
    var max: Float
    var minOperator: Int16
    var maxOperator: Int16
    
    init(color: String, min: Float, max: Float, minOperator: Int16, maxOperator: Int16) {
        self.color = color
        self.min = min
        self.max = max
        self.minOperator = minOperator
        self.maxOperator = maxOperator
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.color as NSString, forKey: LegendEntry.Keys.color.rawValue)
        coder.encode(NSNumber(value: self.min), forKey: LegendEntry.Keys.min.rawValue)
        coder.encode(NSNumber(value: self.max), forKey: LegendEntry.Keys.max.rawValue)
        coder.encode(NSNumber(value: self.minOperator), forKey: LegendEntry.Keys.minOperator.rawValue)
        coder.encode(NSNumber(value: self.maxOperator), forKey: LegendEntry.Keys.maxOperator.rawValue)
    }
    
    required init?(coder: NSCoder) {
        
        guard let color = coder.decodeObject(of: NSString.self, forKey: LegendEntry.Keys.color.rawValue) as String?,
              let min = coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.min.rawValue) as? Float,
              let max = coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.max.rawValue) as? Float,
              let minOperator = coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.minOperator.rawValue) as? Int16,
              let maxOperator = coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.maxOperator.rawValue) as? Int16 else {
            
            let userInfo: [String : Any] =
                ["Message" : "LegendEntry.init() could not decode its properties",
                 LegendEntry.Keys.color.rawValue : coder.decodeObject(of: NSString.self, forKey: LegendEntry.Keys.color.rawValue).debugDescription,
                 LegendEntry.Keys.min.rawValue : coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.min.rawValue).debugDescription,
                 LegendEntry.Keys.max.rawValue : coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.max.rawValue).debugDescription,
                 LegendEntry.Keys.minOperator.rawValue : coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.minOperator.rawValue).debugDescription,
                 LegendEntry.Keys.maxOperator.rawValue : coder.decodeObject(of: NSNumber.self, forKey: LegendEntry.Keys.maxOperator.rawValue).debugDescription]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
            
        }
        
        self.color = color
        self.min = min
        self.max = max
        self.minOperator = minOperator
        self.maxOperator = maxOperator
        
    }
    
}
