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
        guard let task = self.object(with: id) as? Task else {
            let _ = ErrorManager.recordNonFatal(.childContextObject_fetchFailed,
                                                ["fetched object": self.object(with: id).debugDescription])
            return nil
        }
        return task
    }
    
    func childAnalysis(_ id: NSManagedObjectID) -> Analysis? {
        guard let analysis = self.object(with: id) as? Analysis else {
            let _ = ErrorManager.recordNonFatal(.childContextObject_fetchFailed,
                                                ["fetched object": self.object(with: id).debugDescription])
            return nil
        }
        return analysis
    }
    
}
