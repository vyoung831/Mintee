//
//  Extensions.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

extension Date {
    
    // MARK: - Date to String conversion
    
    static let ymdFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    static func toYMDTest(_ date: Date) -> String {
        return ymdFormatter.string(from: date)
    }
    
}

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
