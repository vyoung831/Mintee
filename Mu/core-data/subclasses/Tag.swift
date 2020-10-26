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
     - parameters:
     - tagName: CASE and DIACRITIC insensitive tagName of the Tag to attempt to find
     - returns:
     - Tag NSManagedObject with its tagName set to the input parm tagName
     */
    static func getOrCreateTag ( tagName : String ) -> Tag {
        // Set up case and diacritic insensitive predicate
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.predicate = NSPredicate(format: "name == [cd] %@", tagName)
        do {
            let results = try CDCoordinator.moc.fetch(request)
            if let first = results.first {
                // Return existing tag
                return first
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // No tag already exists in MOC. Return Tag from initiaizlier
        return Tag( tagName: tagName )
    }
    
}
