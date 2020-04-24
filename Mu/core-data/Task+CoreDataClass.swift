//
//  Task+CoreDataClass.swift
//  Mu
//
//  Created by Vincent Young on 4/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(Task)
public class Task: NSManagedObject {
    
    /**
     Takes an array of tag names and adds those as Tags to this Task's tags relationship. Of the tags passed in,
     - New Tags that don't exist in the MOC are created
     - Existing Tags are added to this task's tags
     - Tags that were but are no longer to be related are removed and checked for deletion possibility
     - Parameters:
        - newTagNames: Array of tag names to associate with this Task
     */
    func processTags(newTagNames: [String]) {
        if let moc = self.managedObjectContext {
            
            do {
                // Build a Dictionary with all of MOC's Tags, using each Tag's tagName as key
                let mocTags = try moc.fetch(Tag.fetchRequest())
                var tagDict = Dictionary<String,Tag>()
                for case let mocTag as Tag in mocTags {
                    if let mocTagName = mocTag.tagName {
                        tagDict.updateValue(mocTag, forKey: mocTagName)
                        
                        /*
                         If the new tags don't contain the tagName of the current Tag, check if this Task's tags contains a relationship to that Tag. If it does, remove the relationship and check that Tag for deletion
                         */
                        if !newTagNames.contains(mocTagName) && (self.tags?.contains(mocTag) ?? false)  {
                            self.removeFromTags(mocTag)
                            if mocTag.tasks?.count == 0 {
                                moc.delete(mocTag)
                            }
                        }
                    }
                }
                
                for newTagName in newTagNames {
                    if let existingTag = tagDict[newTagName] {
                        // Tag exists in MOC but isn't related to this Task
                        self.addToTags(existingTag)
                    } else {
                        // Tag doesn't exist in MOC
                        let newTag = Tag(context: moc)
                        newTag.tagName = newTagName
                        self.addToTags(newTag)
                    }
                }
                
            } catch {
                print("Task.processTags failed")
                exit(-1)
            }
        }
    }
    
    /**
     - returns: An array of strings representing the tagNames of this Task's tags
     */
    public func getTagNamesArray() -> [String] {
        if let tags = self.tags as? Set<Tag> {
            let tagNames = tags.map({$0.tagName ?? ""})
            return tagNames
        }
        return []
    }
    
}
