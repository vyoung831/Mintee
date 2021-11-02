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
                  let userInfo: [String : Any] = [AnalysisLegend.Keys.categorizedEntries.rawValue:
                                                    decoder.decodeObject(of: [NSSet.self, CategorizedLegendEntry.self],forKey: AnalysisLegend.Keys.categorizedEntries.rawValue).debugDescription,
                                                  AnalysisLegend.Keys.completionEntries.rawValue:
                                                    decoder.decodeObject(of: [NSSet.self, CompletionLegendEntry.self], forKey: AnalysisLegend.Keys.completionEntries.rawValue).debugDescription]
                  let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, userInfo)
                  self.categorizedEntries = Set()
                  self.completionEntries = Set()
                  return
              }
        self.categorizedEntries = categorizedLegendEntries
        self.completionEntries = completionLegendEntries
        
    }
    
    /**
     Gathers debug descriptions of this AnalysisLegend's legend entries and adds them to an existing inout Dictionary.
     - parameter userInfo: (inout) [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys that this function adds to `userInfo`.
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        
        var idx = 0
        for entry in self.categorizedEntries {
            entry.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(prefix)CategorizedLegendEntry[\(idx)].")
            idx += 1
        }
        
        idx = 0
        for entry in self.completionEntries {
            entry.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(prefix)CompletionLegendEntry[\(idx)].")
            idx += 1
        }
        
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

// MARK: - CategorizedLegendEntry

class CategorizedLegendEntry: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    private var color: String
    private var category: Category
    
    var _category: Category { get { return self.category } }
    var _color: UIColor? {
        get {
            guard let castColor = UIColor(hex: self.color) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    ["color": self.color])
                return nil
            }
            return castColor
        }
    }
    
    enum Category: Int16 {
        case reachedTarget = 1
        case underTarget = 2
        case overTarget = 3
    }
    
    enum Keys: String {
        case category = "category"
        case color = "color"
    }
    
    init(category: Category, color: UIColor) throws {
        guard let hexStringColor = color.toHex() else {
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput,
                                              ["color": color.debugDescription])
        }
        self.category = category
        self.color = hexStringColor
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSNumber(value: self.category.rawValue), forKey: CategorizedLegendEntry.Keys.category.rawValue)
        coder.encode(self.color as NSString, forKey: CategorizedLegendEntry.Keys.color.rawValue)
    }
    
    required init?(coder: NSCoder) {
        
        guard let category = coder.decodeObject(of: NSNumber.self, forKey: CategorizedLegendEntry.Keys.category.rawValue) as? Int16,
              let color = coder.decodeObject(of: NSString.self, forKey: CategorizedLegendEntry.Keys.color.rawValue) as String? else {
                  
                  let userInfo: [String : Any] = [CategorizedLegendEntry.Keys.category.rawValue:
                                                    coder.decodeObject(of: NSNumber.self, forKey: CategorizedLegendEntry.Keys.category.rawValue).debugDescription,
                                                  CategorizedLegendEntry.Keys.color.rawValue:
                                                    coder.decodeObject(of: NSString.self, forKey: CategorizedLegendEntry.Keys.color.rawValue).debugDescription]
                  let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, userInfo)
                  self.color = "00000000"
                  self.category = .reachedTarget
                  return
                  
              }
        
        guard let cat = Category.init(rawValue: category) else {
            let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, ["category": category])
            self.color = "00000000"
            self.category = .reachedTarget
            return
        }
        
        self.category = cat
        self.color = color
        
    }
    
    /**
     Add debug descriptions of this CategorizedLegendEntry and adds them to an inout dictionary
     - parameter userInfo: (inout) [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys that are added  to `userInfo`.
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        userInfo["\(prefix)color"] = self.color
        userInfo["\(prefix)category"] = self.category
    }
    
}

// MARK: - CompletionLegendEntry

class CompletionLegendEntry: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    private var color: String
    private var min: Float
    private var max: Float
    private var minOperator: Int16
    private var maxOperator: Int16
    
    var _min: Float { get { return self.min } }
    var _max: Float { get { return self.max } }
    
    var _color: UIColor? {
        get {
            guard let castColor = UIColor(hex: self.color) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    ["color": self.color])
                return nil
            }
            return castColor
        }
    }
    
    var _minOperator: SaveFormatter.equalityOperator? {
        get {
            guard let minOp = SaveFormatter.equalityOperator.init(rawValue: self.minOperator) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    ["minOperator": self.minOperator])
                return nil
            }
            return minOp
        }
    }
    
    var _maxOperator: SaveFormatter.equalityOperator? {
        get {
            guard let maxOp = SaveFormatter.equalityOperator.init(rawValue: self.maxOperator) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                    ["maxOperator": self.maxOperator])
                return nil
            }
            return maxOp
        }
    }
    
    enum Keys: String {
        case color = "color"
        case min = "min"
        case max = "max"
        case minOperator = "minOperator"
        case maxOperator = "maxOperator"
    }
    
    init(color: UIColor, min: Float, max: Float, minOperator: SaveFormatter.equalityOperator, maxOperator: SaveFormatter.equalityOperator) throws {
        guard let hexStringColor = color.toHex() else {
            throw ErrorManager.recordNonFatal(.modelObjectInitializer_receivedInvalidInput, ["color": color.debugDescription])
        }
        self.color = hexStringColor
        self.min = min
        self.max = max
        self.minOperator = minOperator.rawValue
        self.maxOperator = maxOperator.rawValue
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
              let minOp = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.minOperator.rawValue) as? Int16,
              let maxOp = coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.maxOperator.rawValue) as? Int16 else {
                  let userInfo: [String : Any] = [CompletionLegendEntry.Keys.color.rawValue:
                                                    coder.decodeObject(of: NSString.self, forKey: CompletionLegendEntry.Keys.color.rawValue).debugDescription,
                                                  CompletionLegendEntry.Keys.min.rawValue:
                                                    coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.min.rawValue).debugDescription,
                                                  CompletionLegendEntry.Keys.max.rawValue:
                                                    coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.max.rawValue).debugDescription,
                                                  CompletionLegendEntry.Keys.minOperator.rawValue:
                                                    coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.minOperator.rawValue).debugDescription,
                                                  CompletionLegendEntry.Keys.maxOperator.rawValue:
                                                    coder.decodeObject(of: NSNumber.self, forKey: CompletionLegendEntry.Keys.maxOperator.rawValue).debugDescription]
                  let _ = ErrorManager.recordNonFatal(.transformable_decodingFailed, userInfo)
                  self.color = "00000000"
                  self.min = 0; self.max = 1
                  self.minOperator = SaveFormatter.equalityOperator.lt.rawValue
                  self.maxOperator = SaveFormatter.equalityOperator.lt.rawValue
                  return
              }
        
        self.color = color
        self.min = min
        self.max = max
        self.minOperator = minOp
        self.maxOperator = maxOp
        
    }
    
    /**
     Add debug descriptions of this CompletionLegendEntry and adds them to an inout dictionary
     - parameter userInfo: (inout) [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys that are added  to `userInfo`.
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        userInfo["\(prefix)color"] = self.color
        userInfo["\(prefix)min"] = self.min
        userInfo["\(prefix)max"] = self.max
        userInfo["\(prefix)minOperator"] = self.minOperator
        userInfo["\(prefix)maxOperator"] = self.maxOperator
    }
    
}
