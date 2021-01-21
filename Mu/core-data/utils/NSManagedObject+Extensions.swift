//
//  NSManagedObject+Extensions.swift
//  Mu
//
//  Created by Vincent Young on 6/24/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /**
     Returns an NSEntityDescription for unit testing
     Because this project's unit tests use their own test MOC, they need the NSEntityDescriptions from that MOC rather than from the NSManagedObject itself
     - parameter context: The context from which to retrieve the NSEntityDescription from
     - returns: NSEntityDescription for this NSManagedObject in the provided MOC
     */
    public static func getEntityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)
    }
    
}
