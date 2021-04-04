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
    @NSManaged private var tags: NSSet?
    
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
                     tags: Set<String>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
        self.startDate = SaveFormatter.dateToStoredString(startDate)
        self.endDate = SaveFormatter.dateToStoredString(endDate)
        self.legend = legend
        try self.associateTags(tags)
    }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?,
                     name: String,
                     type: SaveFormatter.analysisType,
                     dateRange: Int16,
                     legend: AnalysisLegend,
                     tags: Set<String>) throws {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.analysisType = SaveFormatter.analysisTypeToStored(type)
        self.dateRange = dateRange
        self.legend = legend
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
