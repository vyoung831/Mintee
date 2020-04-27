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
     - Unrelated Tags are removed and checked for deletion
     - New Tags that don't exist in the MOC are created
     - Existing Tags are added to this task's tags
     - Parameters:
     - newTagNames: Array of tag names to associate with this Task
     */
    public func updateTags(newTagNames: [String]) {
        
        // Remove unrelated tags and check for deletion
        self.removeUnrelatedTags(newTagNames: newTagNames)
        
        var mocTags = Dictionary<String,Tag>()
        let tagFetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            // Build dictionary with the MOC's Tags as values and their tagNames as keys
            for case let existingTag in try CDCoordinator.moc.fetch(tagFetchRequest) {
                mocTags.updateValue(existingTag, forKey: existingTag.tagName!)
            }
            
            // For each tag passed in, check if it already exists using the MOC tagName dictionary. If it does, add it to the tags relationship. If not, create a new Tag in the MOC and add to tags.
            for newTagName in newTagNames {
                if let existingTag = mocTags[newTagName] {
                    self.addToTags(existingTag)
                } else {
                    let newTag = Tag(context: CDCoordinator.moc)
                    newTag.tagName = newTagName
                    self.addToTags(newTag)
                }
            }
            
        } catch { print("Task.updateTags encountered error when fetching Tags") }
    }
    
    /**
     Takes in an array of tag names to associate with this Task and loops through the existing tags relationship, removing those Tags that are no longer to be associated and checking them for deletion
     - Parameters:
     - newTagNames: Array of tag names to associate with this Task
     */
    private func removeUnrelatedTags(newTagNames: [String]) {
        if let tags = self.tags {
            for case let tag as Tag in tags {
                
                // If new tags don't contain an existing Tag's tagName, remove it from tags. After, if the Tag has no Tasks left, delete it
                if !newTagNames.contains(tag.tagName!) {
                    self.removeFromTags(tag)
                    if tag.tasks?.count == 0 {
                        CDCoordinator.moc.delete(tag)
                    }
                }
                
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
