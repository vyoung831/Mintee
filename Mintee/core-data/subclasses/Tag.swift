//
//  Tag+CoreDataClass.swift
//  Mintee
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData
import Firebase

@objc(Tag)
public class Tag: NSManagedObject {
    
    @NSManaged private var name: String
    @NSManaged private var tasks: NSSet
    @NSManaged private var analyses: NSSet?
    
    var _name: String { get { return self.name } }
    
    var _tasks: Set<Task> {
        get throws {
            guard let castSet = self.tasks as? Set<Task> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData)
            }
            return castSet
        }
    }
    
    var _analyses: Set<Analysis> {
        get throws {
            guard let unwrappedSet = self.analyses else { return Set<Analysis>() }
            guard let castSet = unwrappedSet as? Set<Analysis> else {
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, ["unwrappedSet.debugDescription": unwrappedSet.debugDescription])
            }
            return castSet
        }
    }
    
    /**
     Creates a Tag instance and inserts it into the shared MOC. This initializer should only be used if there is no existing Tag with tagName=$tagName in the MOC.
     - parameter tagName: String to set new Tag's name to.
     - parameter moc: The MOC in which to perform updates.
     */
    private convenience init(tagName: String,_ moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.name = tagName
    }
    
    /**
     Creates new or finds existing Tags with the names specified and associates with the provided Task.
     - parameter tagNames: Name of tags to find/create and associate with the Task.
     - parameter task: The Task to associate Tags with.
     - parameter moc: The MOC in which to search for Tags and perform updates.
     */
    static func associateTags(tagNames: Set<String>,_ task: Task,_ moc: NSManagedObjectContext) throws {
        for tagName in tagNames {
            let request = NSFetchRequest<Tag>(entityName: "Tag")
            request.predicate = NSPredicate(format: "name == [cd] %@", tagName) // Case and diacritic insensitive predicate
            var results: [Tag] = []
            do {
                results = try moc.fetch(request)
            } catch {
                throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                                  ["request" : request.debugDescription,
                                                   "error.localizedDescription" : error.localizedDescription])
            }
            guard let first = results.first else {
                Tag(tagName: tagName, moc).addToTasks(task)
                continue
            }
            first.addToTasks(task)
        }
    }
    
    /**
     Finds existing Tags with the names specified and associates with the provided Analysis.
     - parameter tagNames: Name of tags to find and associate with the Analysis.
     - parameter task: The Analysis to associate Tags with.
     - parameter moc: The MOC in which to search for Tags and perform updates.
     */
    static func associateTags(tagNames: Set<String>,_ analysis: Analysis,_ moc: NSManagedObjectContext) throws {
        for tagName in tagNames {
            let request = NSFetchRequest<Tag>(entityName: "Tag") // TO-DO: Update FetchRequest with more robust way to obtain name of `Tag` entity.
            request.predicate = NSPredicate(format: "name == [cd] %@", tagName) // Case and diacritic insensitive predicate
            var results: [Tag] = []
            do {
                results = try moc.fetch(request)
            } catch {
                throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                                  ["request" : request.debugDescription,
                                                   "error.localizedDescription" : error.localizedDescription])
            }
            guard let first = results.first else {
                throw ErrorManager.recordNonFatal(.fetchRequest_failed)
            }
            first.addToAnalyses(analysis)
        }
    }
    
}

// MARK:- Generated accessors for analyses

extension Tag {
    
    @objc(addAnalysesObject:)
    @NSManaged private func addToAnalyses(_ value: Analysis)
    
    @objc(removeAnalysesObject:)
    @NSManaged private func removeFromAnalyses(_ value: Analysis)
    
    @objc(addAnalyses:)
    @NSManaged private func addToAnalyses(_ values: NSSet)
    
    @objc(removeAnalyses:)
    @NSManaged private func removeFromAnalyses(_ values: NSSet)
    
}

// MARK:- Generated accessors for tasks

extension Tag {
    
    @objc(addTasksObject:)
    @NSManaged private func addToTasks(_ value: Task)
    
    @objc(removeTasksObject:)
    @NSManaged private func removeFromTasks(_ value: Task)
    
    @objc(addTasks:)
    @NSManaged private func addToTasks(_ values: NSSet)
    
    @objc(removeTasks:)
    @NSManaged private func removeFromTasks(_ values: NSSet)
    
}
