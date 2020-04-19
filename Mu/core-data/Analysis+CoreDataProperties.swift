//
//  Analysis+CoreDataProperties.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData


extension Analysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Analysis> {
        return NSFetchRequest<Analysis>(entityName: "Analysis")
    }

    @NSManaged public var analysisEnd: Date?
    @NSManaged public var analysisName: String?
    @NSManaged public var analysisStart: Date?
    @NSManaged public var analysisType: String?
    @NSManaged public var legendEntries: NSSet?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for legendEntries
extension Analysis {

    @objc(addLegendEntriesObject:)
    @NSManaged public func addToLegendEntries(_ value: LegendEntry)

    @objc(removeLegendEntriesObject:)
    @NSManaged public func removeFromLegendEntries(_ value: LegendEntry)

    @objc(addLegendEntries:)
    @NSManaged public func addToLegendEntries(_ values: NSSet)

    @objc(removeLegendEntries:)
    @NSManaged public func removeFromLegendEntries(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Analysis {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
