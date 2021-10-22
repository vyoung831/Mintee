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
    @NSManaged private var tags: NSSet?
    @NSManaged private var startDate: String?
    @NSManaged private var endDate: String?
    @NSManaged private var dateRange: Int16
    @NSManaged private var order: Int16
    @NSManaged private var legend: AnalysisLegend
    
    var _name: String { get { return self.name } set { self.name = newValue } }
    var _tags: NSSet? { get { return self.tags } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _order: Int16 { get { return self.order }}
    var _legend: AnalysisLegend { get { return self.legend } }
    
    var _analysisType: SaveFormatter.analysisType? {
        get {
            guard let type = SaveFormatter.analysisType.init(rawValue: self.analysisType) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary("An Analysis' analysisType couldn't be converted to a valid analysisType"))
                return nil
            }
            return type
        }
    }
    
    var _startDate: Date? {
        get {
            guard let startDateString = self.startDate else { return nil }
            guard let formattedDate = SaveFormatter.storedStringToDate(startDateString) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary("An Analysis' startDate couldn't be converted to a valid Date"))
                return nil
            }
            return formattedDate
        }
    }
    var _endDate: Date? {
        get {
            guard let endDateString = self.endDate else { return nil }
            guard let formattedDate = SaveFormatter.storedStringToDate(endDateString) else {
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, self.mergeDebugDictionary("An Analysis' endDate couldn't be converted to a valid Date"))
                return nil
            }
            return formattedDate
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
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext,
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
        try self.updateTags(tags, context)
    }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext,
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
        try self.updateTags(tags, context)
    }
    
}

// MARK: - Debug logging

extension Analysis {
    
    /**
     Gathers debug descriptions of this Analysis' legend and tags, and adds them to an existing inout Dictionary.
     - parameter userInfo: (inout) [String : Any] Dictionary containing existing debug info.
     - parameter prefix: String to be prepended to keys that this function adds to `userInfo`.
     */
    func mergeDebugDictionary(userInfo: inout [String : Any], prefix: String = "") {
        
        // Add associated tag names
        if let tagsArray = self.tags?.sortedArray(using: []) as? [Tag] {
            var tagsIndex = 0
            for unwrappedTag in tagsArray {
                userInfo["\(prefix)tags[\(tagsIndex)]"] = unwrappedTag._name
                tagsIndex += 1
            }
        }
        
        // Add AnalysisLegend debug info
        self.legend.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(prefix)legend.")
        
    }
    
    /**
     Gathers debug descriptions of this Analysis' into a dictionary.
     - parameter message: Value to set to key "Message".
     - returns: Dictionary containing debug descriptions of this Analysis and its legend.
     */
    func mergeDebugDictionary(_ message: String) -> [String: Any] {
        
        var userInfo: [String: Any] = [:]
        
        // Add associated tag names
        if let tagsArray = self.tags?.sortedArray(using: []) as? [Tag] {
            var tagsIndex = 0
            for unwrappedTag in tagsArray {
                userInfo["tags[\(tagsIndex)]"] = unwrappedTag._name
                tagsIndex += 1
            }
        }
        
        // Add AnalysisLegend debug info
        self.legend.mergeDebugDictionary(userInfo: &userInfo, prefix: "legend.")
        return userInfo
        
    }
    
}

// MARK: - Tag utility functions

extension Analysis {
    
    /**
     - returns: A set of strings representing the tagNames of this Analysis' tags
     */
    func getTagNames() -> Set<String> {
        if let tags = self.tags as? Set<Tag> {
            return Set(tags.map({$0._name}))
        }
        return Set<String>()
    }
    
    /**
     Updates this Analysis' tags relationship to contain only the Tags passed in.
     - parameter newTagNames: Set of names of Tags to set as this Analysis' tags.
     - parameter moc: The MOC to update this perform updates in.
     */
    func updateTags(_ newTagNames: Set<String>,_ moc: NSManagedObjectContext) throws {
        self.removeUnrelatedTags(newTagNames: newTagNames)
        try Tag.associateTags(tagNames: newTagNames, self, moc)
    }
    
    /**
     Removes Tags that are no longer to be associated with this Analysis.
     Tags that were already but no longer to be associated with this Analysis are removed.
     - parameter newTagNames: Set of names of Tags to set as this Analysis' tags.
     */
    private func removeUnrelatedTags(newTagNames: Set<String>) {
        if let tags = self.tags as? Set<Tag> {
            for tag in tags {
                !newTagNames.contains(tag._name) ? self.removeFromTags(tag) : nil
            }
        }
    }
    
}

// MARK: - Ordering utility functions

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

// MARK: - Legend update functions

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
     - parameter analysistype: Value of type `SaveFormatter.analysisType` to assign to this Analysis
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
