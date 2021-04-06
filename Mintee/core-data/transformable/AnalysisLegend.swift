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
    var categorizedEntries: Set<CategorizedLegendEntry>
    var completionEntries: Set<CompletionLegendEntry>
    
    enum Keys: String {
        case categorizedEntries = "categorizedEntries"
        case completionEntries = "completionEntries"
    }
    
    enum EntryType: Int16 {
        case categorized = 1
        case completion = 2
    }
    
    init(categorizedEntries: Set<CategorizedLegendEntry>, completionEntries: Set<CompletionLegendEntry>) {
        self.categorizedEntries = categorizedEntries
        self.completionEntries = completionEntries
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSSet(set: self.categorizedEntries), forKey: AnalysisLegend.Keys.categorizedEntries.rawValue)
        coder.encode(NSSet(set: self.completionEntries), forKey: AnalysisLegend.Keys.completionEntries.rawValue)
    }
    
    required init?(coder decoder: NSCoder) {
        
        guard let categorizedLegendEntries = decoder.decodeObject(of: [NSSet.self, CategorizedLegendEntry.self], forKey: AnalysisLegend.Keys.categorizedEntries.rawValue ) as? Set<CategorizedLegendEntry>,
              let completionLegendEntries = decoder.decodeObject(of: [NSSet.self, CompletionLegendEntry.self], forKey: AnalysisLegend.Keys.completionEntries.rawValue ) as? Set<CompletionLegendEntry> else {
            let userInfo: [String : Any] = ["Message" : "AnalysisLegend.init() could not decode its entries",
                                            AnalysisLegend.Keys.categorizedEntries.rawValue : decoder.decodeObject(of: [NSSet.self, CategorizedLegendEntry.self], forKey: AnalysisLegend.Keys.categorizedEntries.rawValue).debugDescription,
                                            AnalysisLegend.Keys.completionEntries.rawValue : decoder.decodeObject(of: [NSSet.self, CompletionLegendEntry.self], forKey: AnalysisLegend.Keys.completionEntries.rawValue).debugDescription]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        self.categorizedEntries = categorizedLegendEntries
        self.completionEntries = completionLegendEntries
        
    }
    
    /**
     Gathers debug descriptions of this AnalysisLegend's LegendEntries and their properties.
     - parameter userInfo: [String : Any] Dictionary containing existing debug info
     - returns: Dictionary containing existing debug info + debug descriptions of LegendEntries' properties
     */
    func mergeDebugDictionary(userInfo: [String : Any]) -> [String : Any] {
        
        var debugDictionary: [String : Any] = [:]
        
        var idx = 0;
        for entry in self.categorizedEntries {
            debugDictionary["CategorizedLegendEntry[\(idx)].color"] = entry.color.debugDescription
            debugDictionary["CategorizedLegendEntry[\(idx)].type"] = entry.type
            idx += 1
        }
        
        for entry in self.completionEntries {
            debugDictionary["CompletionLegendEntry[\(idx)].color"] = entry.color.debugDescription
            debugDictionary["CompletionLegendEntry[\(idx)].min"] = entry.min
            debugDictionary["CompletionLegendEntry[\(idx)].max"] = entry.max
            debugDictionary["CompletionLegendEntry[\(idx)].minOperator"] = entry.minOperator
            debugDictionary["CompletionLegendEntry[\(idx)].maxOperator"] = entry.maxOperator
            idx += 1
        }
        
        debugDictionary.merge(userInfo, uniquingKeysWith: {
            return "(Keys clashed).\nValue 1 = \($0)\nValue 2 = \($1)"
        })
        return debugDictionary
    }
    
}

// MARK: - AnalysisLegendTransformer

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

// MARK: - Legend entry types

class CategorizedLegendEntry: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    var color: String
    var type: Category
    
    enum Category: Int16 {
        case reachedTarget = 1
        case underTarget = 2
        case overTarget = 3
    }
    
    enum Keys: String {
        case type = "type"
        case color = "color"
    }
    
    init(type: Category, color: UIColor) throws {
        guard let hexStringColor = color.toHex() else {
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput,
                                              ["Message" : "CategorizedLegendEntry.init() received color that could not converted to a hex String",
                                               "color" : color.debugDescription])
        }
        self.type = type
        self.color = hexStringColor
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSNumber(value: self.type.rawValue), forKey: CategorizedLegendEntry.Keys.type.rawValue)
        coder.encode(self.color as NSString, forKey: CategorizedLegendEntry.Keys.color.rawValue)
    }
    
    required init?(coder: NSCoder) {
        
        guard let type = coder.decodeObject(of: NSNumber.self, forKey: CategorizedLegendEntry.Keys.type.rawValue) as? Int16,
              let color = coder.decodeObject(of: NSString.self, forKey: CategorizedLegendEntry.Keys.color.rawValue) as String? else {
            
            let userInfo: [String : Any] = ["Message" : "CategorizedLegendEntry.init() could not decode its properties",
                                            CategorizedLegendEntry.Keys.type.rawValue : coder.decodeObject(of: NSNumber.self, forKey: CategorizedLegendEntry.Keys.type.rawValue).debugDescription,
                                            CategorizedLegendEntry.Keys.color.rawValue : coder.decodeObject(of: NSString.self, forKey: CategorizedLegendEntry.Keys.color.rawValue).debugDescription]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
            
        }
        
        guard let category = Category.init(rawValue: type) else {
            let userInfo: [String : Any] = ["Message" : "CategorizedLegendEntry.init() found an Int16 under `type` that could not be converted to a valid value of type Category",
                                            "type" : type]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        
        self.type = category
        self.color = color
        
    }
    
}

class CompletionLegendEntry: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    var color : String
    var min: Float
    var max: Float
    var minOperator: Int16
    var maxOperator: Int16
    
    enum Keys: String {
        case color = "color"
        case min = "min"
        case max = "max"
        case minOperator = "minOperator"
        case maxOperator = "maxOperator"
    }
    
    init(color: UIColor, min: Float, max: Float, minOperator: SaveFormatter.equalityOperator, maxOperator: SaveFormatter.equalityOperator) throws {
        guard let hexStringColor = color.toHex() else {
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput,
                                              ["Message" : "CompletionLegendEntry.init() received UIColor that could not converted to a hex String",
                                               "color" : color.debugDescription])
        }
        self.color = hexStringColor
        self.min = min
        self.max = max
        self.minOperator = SaveFormatter.equalityOperatorToStored(minOperator)
        self.maxOperator = SaveFormatter.equalityOperatorToStored(maxOperator)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.color as NSString, forKey: CompletionLegendEntry.Keys.color.rawValue)
        coder.encode(NSNumber(value: self.min), forKey: CompletionLegendEntry.Keys.min.rawValue)
        coder.encode(NSNumber(value: self.max), forKey: CompletionLegendEntry.Keys.max.rawValue)
        coder.encode(NSNumber(value: self.minOperator), forKey: CompletionLegendEntry.Keys.minOperator.rawValue)
        coder.encode(NSNumber(value: self.maxOperator), forKey: CompletionLegendEntry.Keys.maxOperator.rawValue)
    }
    
    required init?(coder: NSCoder) {
        
        guard let color = coder.decodeObject(of: NSString.self, forKey: CompletionLegendEntry.Keys.color.rawValue) as String?,
              let min = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.min.rawValue) as? Float,
              let max = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.max.rawValue) as? Float,
              let minOperator = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.minOperator.rawValue) as? Int16,
              let maxOperator = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.maxOperator.rawValue) as? Int16 else {
            
            let userInfo: [String : Any] = ["Message" : "CompletionLegendEntry.init() could not decode its properties",
                                            CompletionLegendEntry.Keys.color.rawValue : coder.decodeObject(of: NSString.self, forKey: CompletionLegendEntry.Keys.color.rawValue).debugDescription,
                                            CompletionLegendEntry.Keys.min.rawValue : coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.min.rawValue).debugDescription,
                                            CompletionLegendEntry.Keys.max.rawValue : coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.max.rawValue).debugDescription,
                                            CompletionLegendEntry.Keys.minOperator.rawValue : coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.minOperator.rawValue).debugDescription,
                                            CompletionLegendEntry.Keys.maxOperator.rawValue : coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.maxOperator.rawValue).debugDescription]
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
