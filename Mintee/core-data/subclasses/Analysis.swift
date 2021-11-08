//
//  Analysis+CoreDataClass.swift
//  Mintee
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Analysis)
public class Analysis: NSManagedObject {
    
    @NSManaged private var name: String
    @NSManaged private var analysisType: Int16
    @NSManaged private var rangeType: Int16
    @NSManaged private var startDate: String?
    @NSManaged private var endDate: String?
    @NSManaged private var dateRange: Int16
    @NSManaged private var order: Int16
    @NSManaged private var legend: AnalysisLegend
    @NSManaged private var tags: NSSet?
    
    var _name: String { get { return self.name } set { self.name = newValue } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _order: Int16 { get { return self.order }}
    var _legend: AnalysisLegend { get { return self.legend } }
    
    var _analysisType: SaveFormatter.analysisType {
        get throws {
            guard let type = SaveFormatter.analysisType.init(rawValue: self.analysisType) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return type
        }
    }
    
    var _rangeType: SaveFormatter.analysisRangeType {
        get throws {
            guard let type = SaveFormatter.analysisRangeType.init(rawValue: self.rangeType) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return type
        }
    }
    
    var _startDate: Date? {
        get throws {
            guard let startDateString = self.startDate else {
                if (try self._rangeType) == .startEnd {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                return nil
            }
            guard let formattedDate = SaveFormatter.storedStringToDate(startDateString) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return formattedDate
        }
    }
    
    var _endDate: Date? {
        get throws {
            guard let endDateString = self.endDate else {
                if (try self._rangeType) == .startEnd {
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
                }
                return nil
            }
            guard let formattedDate = SaveFormatter.storedStringToDate(endDateString) else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return formattedDate
        }
    }
    
    var _tags: Set<Tag> {
        get throws {
            guard let unwrappedSet = self.tags else { return Set() }
            guard let castedSet = unwrappedSet as? Set<Tag> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary())
            }
            return castedSet
        }
    }
    
}

// MARK:- Generated accessors for tags

extension Analysis {
    
    @objc(addTagsObject:)
    @NSManaged private func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged private func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged private func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged private func removeFromTags(_ values: NSSet)
    
}

// MARK: - Initializers, deletion, and entity association utility funcs

extension Analysis {
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext,
                     name: String,
                     type: SaveFormatter.analysisType,
                     startDate: Date,
                     endDate: Date,
                     legend: AnalysisLegend,
                     order: Int16,
                     tags: Set<String>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = type.rawValue
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        self.legend = legend
        self.order = order
        self.rangeType = SaveFormatter.analysisRangeType.startEnd.rawValue
        try self.updateTags(tags, context)
    }
    
    convenience init(entity: NSEntityDescription,
                     insertInto context: NSManagedObjectContext,
                     name: String,
                     type: SaveFormatter.analysisType,
                     dateRange: Int16,
                     legend: AnalysisLegend,
                     order: Int16,
                     tags: Set<String>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = type.rawValue
        self.dateRange = dateRange
        self.legend = legend
        self.order = order
        self.rangeType = SaveFormatter.analysisRangeType.dateRange.rawValue
        try self.updateTags(tags, context)
    }
    
}

// MARK: - Debug logging

extension Analysis {
    
    /**
     Gathers debug descriptions of this Analysis' legend and tags, and adds them to an existing inout Dictionary.
     - parameter userInfo: (inout) [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys added to `userInfo`.
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        
        userInfo["\(prefix)name"] = self.name
        userInfo["\(prefix)analysisType"] = self.analysisType
        userInfo["\(prefix)rangeType"] = self.rangeType
        userInfo["\(prefix)startDate"] = self.startDate
        userInfo["\(prefix)endDate"] = self.endDate
        userInfo["\(prefix)dateRange"] = self.dateRange
        userInfo["\(prefix)order"] = self.order
        
        self.legend.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(prefix)legend.")
        
        if let tagsArray = self.tags?.sortedArray(using: []) as? [Tag] {
            var tagsIndex = 0
            for unwrappedTag in tagsArray {
                userInfo["\(prefix)tags[\(tagsIndex)]"] = unwrappedTag._name
                tagsIndex += 1
            }
        }
        
    }
    
    /**
     Gathers debug descriptions of this Analysis' into a dictionary.
     - parameter prefix: String to be prepended to keys added to `userInfo`.
     - returns: Dictionary containing debug descriptions of this Analysis and its legend.
     */
    func mergeDebugDictionary(prefix: String = "") -> [String: Any] {
        var userInfo: [String: Any] = [:]
        self.mergeDebugDictionary(userInfo: &userInfo, prefix: prefix)
        return userInfo
    }
    
}

// MARK: - Tag helper functions

extension Analysis {
    
    /**
     Updates this Analysis' tags relationship to contain only the Tags passed in.
     - parameter newTagNames: Set of names of Tags to set as this Analysis' tags.
     - parameter moc: The MOC to perform updates in.
     */
    func updateTags(_ newTagNames: Set<String>,_ moc: NSManagedObjectContext) throws {
        try self.removeUnrelatedTags(newTagNames: newTagNames)
        try Tag.associateTags(tagNames: newTagNames, self, moc)
    }
    
    /**
     Removes Tags that are no longer to be associated with this Analysis.
     - parameter newTagNames: Set of names of Tags to set as this Analysis' tags.
     */
    private func removeUnrelatedTags(newTagNames: Set<String>) throws {
        for tag in try self._tags {
            !newTagNames.contains(tag._name) ? self.removeFromTags(tag) : nil
        }
    }
    
}

// MARK: - Ordering helper functions

extension Analysis {
    
    /**
     Sets the order in which this Analysis will be displayed on the Analysis homepage. Highest priority `order` = 0
     - parameter order: The Int16 to assign to this Analysis' `order`.
     */
    func setOrder(_ order: Int16) {
        self.order = order
    }
    
    /**
     Marks this Analysis as not to be displayed on the Analysis homepage.
     */
    func setUnincluded() {
        self.order = -1
    }
    
}

// MARK: - Legend helper functions

extension Analysis {
    
    /**
     Initializes a new instance of AnalysisLegend and assigns it to this Analysis.
     - parameter categorizedEntries: Set of `CategorizedLegendEntry` to use to build new AnalysisLegend.
     */
    func updateLegend(categorizedEntries: Set<CategorizedLegendEntry>) {
        let legend = AnalysisLegend(categorizedEntries: categorizedEntries, completionEntries: Set())
        self.legend = legend
    }
    
    /**
     Initializes a new instance of AnalysisLegend and assigns it to this Analysis.
     - parameter completionEntries: Set of `CompletionLegendEntry` to use to build new AnalysisLegend.
     */
    func updateLegend(completionEntries: Set<CompletionLegendEntry>) {
        let legend = AnalysisLegend(categorizedEntries: Set(), completionEntries: completionEntries)
        self.legend = legend
    }
    
}

// MARK: - Date and rangeType functions

extension Analysis {
    
    /**
     Updates this Analysis' start and end dates and resets dateRange to the default Int16 value.
     - parameter start: New start date
     - parameter end: New end date
     */
    func updateStartAndEndDates(start: Date, end: Date) {
        self.startDate = SaveFormatter.dateToStoredString(start)
        self.endDate = SaveFormatter.dateToStoredString(end)
        self.dateRange = 0 // TO-DO: Update this assignment with a more robust way of obtaining the default value that Core Data assigns to Int16
    }
    
    /**
     Updates dateRange and resets startDate and endDate to nil.
     - parameter range: New dateRange value
     */
    func updateDateRange(_ range: Int16) {
        self.dateRange = range
        self.startDate = nil
        self.endDate = nil
    }
    
}

// MARK: - analysisType functions

extension Analysis {
    
    /**
     - parameter type: Value of type `SaveFormatter.analysisType` to assign to this Analysis.
     */
    func updateAnalysisType(_ type: SaveFormatter.analysisType) {
        self.analysisType = type.rawValue
    }
    
}

// MARK: - Deletion

extension Analysis {
    
    /**
     Deletes this Analysis.
     - parameter moc: The MOC in which to perform updates.
     */
    func deleteSelf(_ moc: NSManagedObjectContext) {
        moc.delete(self)
    }
    
}
