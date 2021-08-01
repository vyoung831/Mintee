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
    var _analysisType: Int16 { get { return self.analysisType } }
    var _tags: NSSet? { get { return self.tags } }
    var _startDate: String? { get { return self.startDate } }
    var _endDate: String? { get { return self.endDate } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _order: Int16 { get { return self.order }}
    var _legend: AnalysisLegend { get { return self.legend } }
    
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
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?,
                     name: String,
                     type: SaveFormatter.analysisType,
                     startDate: Date,
                     endDate: Date,
                     legend: AnalysisLegend,
                     order: Int16,
                     tags: Set<Tag>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        self.legend = legend
        self.order = order
        try self.associateTags(tags)
    }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?,
                     name: String,
                     type: SaveFormatter.analysisType,
                     dateRange: Int16,
                     legend: AnalysisLegend,
                     order: Int16,
                     tags: Set<Tag>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
        self.dateRange = dateRange
        self.legend = legend
        self.order = order
        try self.associateTags(tags)
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
    
}

// MARK: - Tag utility functions

extension Analysis {
    
    /**
     - returns: A set of strings representing the tagNames of this Analysis' tags
     */
    func getTagNames() -> Set<String> {
        if let tags = self.tags as? Set<Tag> {
            let tagNames = Set(tags.map({$0._name ?? ""}))
            return tagNames
        }
        return Set<String>()
    }
    
    /**
     Updates this Analysis' tags relationship to contain only the Tags passed in.
     - parameter tags: Set of Tags to be set as this Analysis' tags relationship
     */
    func associateTags(_ tags: Set<Tag>) throws {
        self.removeUnrelatedTags(newTags: tags)
        for tag in tags {
            self.addToTags(tag) // NSSet ignores dupliates
        }
    }
    
    /**
     Removes Tags that are no longer to be associated with this Analysis.
     Tags that were already but no longer to be associated with this Analysis are removed.
     - parameter newTags: Set of Tags to be set as this Analysis' tags relationship
     */
    private func removeUnrelatedTags(newTags: Set<Tag>) {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                if !newTags.contains(tag) {
                    self.removeFromTags(tag)
                }
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
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
    }
    
}

// MARK: - Deletion

extension Analysis {
    
    /**
     Deletes this Analysis.
     */
    func deleteSelf() {
        CDCoordinator.moc.delete(self)
    }
    
}
