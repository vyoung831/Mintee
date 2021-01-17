//
//  Tag+CoreDataClass.swift
//  Mu
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
    
    @NSManaged private var name: String?
    @NSManaged private var analyses: NSSet?
    @NSManaged private var tasks: NSSet?
    
    var _name: String? { get { return self.name } }
    var _analyses: NSSet? { get { return self.analyses } }
    var _tasks: NSSet? { get { return self.tasks } }
    
    /**
     Creates a Tag instance and inserts it into the shared MOC. This initializer should only be used if there is no existing Tag with tagName=$tagName in the MOC.
     - parameters:
     - tagName: String to set new Tag's tagName to
     */
    private convenience init( tagName : String ) {
        if let entity = NSEntityDescription.entity(forEntityName: "Tag", in: CDCoordinator.moc) {
            self.init(entity: entity, insertInto: CDCoordinator.moc)
            self.name = tagName
        } else {
            Crashlytics.crashlytics().log("Could not get NSEntityDescription for Tag")
            fatalError()
        }
    }
    
    /**
     Given a tagName, either returns the existing Tag object with that tagName or creates a new one.
     This function attempts to fetch an existing Tag by tagName using a CASE and DIACRITIC insensitive predicate
     - parameter tagName: Case and diacritic insensitive tagName of the Tag to attempt to find
     - returns: Tag NSManagedObject with its tagName set to the input parm tagName
     */
    static func getOrCreateTag ( tagName : String ) throws -> Tag {
        
        if tagName.count < 1 {
            let userInfo: [String : Any] = ["Message" : "Tag.getOrCreateTag() received tagName with count < 1"]
            throw ErrorManager.recordNonFatal(.modelFunction_receivedInvalidInput, userInfo)
        }
        
        // Set up case and diacritic insensitive predicate
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.predicate = NSPredicate(format: "name == [cd] %@", tagName)
        do {
            let results = try CDCoordinator.moc.fetch(request)
            if let first = results.first {
                // Return existing tag
                return first
            }
        } catch (let error) {
            Crashlytics.crashlytics().log("FetchRequest for Tag failed in Tag.getOrCreateTag()")
            Crashlytics.crashlytics().setCustomValue(error.localizedDescription, forKey: "Error localized description")
            fatalError()
        }
        
        // No tag already exists in MOC. Return Tag from initiaizlier
        return Tag( tagName: tagName )
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
