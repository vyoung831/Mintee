//
//  NSManagedObjectContext+Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 10/21/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func childTask(_ id: NSManagedObjectID) -> Task? {
        if let task = self.object(with: id) as? Task {
            return task
        } else {
            let _ = ErrorManager.recordNonFatal(.childContextObject_fetchFailed,
                                                ["fetched object": self.object(with: id).debugDescription])
            return nil
        }
    }
    
    func childAnalysis(_ id: NSManagedObjectID) -> Analysis? {
        if let analysis = self.object(with: id) as? Analysis {
            return analysis
        } else {
            let _ = ErrorManager.recordNonFatal(.childContextObject_fetchFailed,
                                                ["fetched object": self.object(with: id).debugDescription])
            return nil
        }
    }
    
}
