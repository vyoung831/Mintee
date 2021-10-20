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
    @NSManaged private var analyses: NSSet?
    @NSManaged private var tasks: NSSet
    
    var _name: String { get { return self.name } }
    var _analyses: NSSet? { get { return self.analyses } }
    var _tasks: NSSet { get { return self.tasks } }
    
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
            do {
                let results = try moc.fetch(request)
                if let first = results.first {
                    first.addToTasks(task)
                } else {
                    Tag(tagName: tagName, moc).addToTasks(task)
                }
            } catch {
                moc.rollback()
                throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                                  ["Message" : "Tag.associateTags() failed to execute NSFetchRequest",
                                                   "request" : request.debugDescription,
                                                   "error.localizedDescription" : error.localizedDescription])
            }
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
            do {
                let results = try moc.fetch(request)
                if let first = results.first {
                    first.addToAnalyses(analysis)
                } else {
                    throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                                      ["Message" : "Tag.associateTags() could not find an existing Tag to associate with an Analysis"])
                }
            } catch {
                moc.rollback()
                throw ErrorManager.recordNonFatal(.fetchRequest_failed,
                                                  ["Message" : "Tag.associateTags() failed to execute NSFetchRequest",
                                                   "request" : request.debugDescription,
                                                   "error.localizedDescription" : error.localizedDescription])
            }
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
