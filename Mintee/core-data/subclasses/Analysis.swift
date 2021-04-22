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
    
    @NSManaged private var analysisType: Int16
    @NSManaged private var endDate: String?
    @NSManaged private var legend: AnalysisLegend?
    @NSManaged private var name: String?
    @NSManaged private var startDate: String?
    @NSManaged private var dateRange: Int16
    @NSManaged private var order: Int16
    @NSManaged private var tags: NSSet?
    
    var _order: Int16 { get { return self.order }}
    var _name: String? { get { return self.name } }
    var _analysisType: Int16 { get { return self.analysisType } }
    var _startDate: String? { get { return self.startDate } }
    var _endDate: String? { get { return self.endDate } }
    var _dateRange: Int16 { get { return self.dateRange } }
    var _legend: AnalysisLegend? { get { return self.legend } }
    var _tags: NSSet? { get { return self.tags } }
    
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
                     tags: Set<String>) throws {
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
                     tags: Set<String>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
        self.dateRange = dateRange
        self.legend = legend
        self.order = order
        try self.associateTags(tags)
    }
    
    /**
     Gets new or existing Tags with the given names, and associates them with this Analysis.
     - parameter tags: Set of Strings for which to get/create Tags by name and associate with this Analysis
     */
    func associateTags(_ tags: Set<String>) throws {
        for tagName in tags {
            let tag = try Tag.getOrCreateTag(tagName: tagName)
            self.addToTags(tag) // NSSet ignores dupliates
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
        self.legend?.mergeDebugDictionary(userInfo: &userInfo, prefix: "\(prefix)legend.")
        
    }
    
}
