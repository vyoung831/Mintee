//
//  Analysis+CoreDataClass.swift
//  Mu
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
    @NSManaged private var name: String?
    @NSManaged private var startDate: String?
    @NSManaged private var legendEntries: NSSet?
    @NSManaged private var tags: NSSet?
    
    var _analysisType: Int16 { get { return self.analysisType } }
    var _endDate: String? { get { return self.endDate } }
    var _name: String? { get { return self.name } }
    var _startDate: String? { get { return self.startDate } }
    var _legendEntries: NSSet? { get { return self.legendEntries } }
    var _tags: NSSet? { get { return self.tags } }
    
}

// MARK:-  Generated accessors for legendEntries

extension Analysis {
    
    @objc(addLegendEntriesObject:)
    @NSManaged private func addToLegendEntries(_ value: LegendEntry)
    
    @objc(removeLegendEntriesObject:)
    @NSManaged private func removeFromLegendEntries(_ value: LegendEntry)
    
    @objc(addLegendEntries:)
    @NSManaged private func addToLegendEntries(_ values: NSSet)
    
    @objc(removeLegendEntries:)
    @NSManaged private func removeFromLegendEntries(_ values: NSSet)
    
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
