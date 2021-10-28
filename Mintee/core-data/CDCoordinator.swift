//
//  CDCoordinator.swift
//  Mintee
//
//  Created by Vincent Young on 4/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Core Data stack

class CDCoordinator {
    
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it.
     */
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Mintee")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let unwrappedError = error as NSError? {
                var debugData = unwrappedError.userInfo
                debugData["storeDescription"] = storeDescription
                let _ = ErrorManager.recordNonFatal(.persistentStore_loadFailed, debugData)
                NotificationCenter.default.post(name: .persistentStore_loadFailed, object: nil)
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

// MARK: - Concurrency support

extension CDCoordinator {
    
    static var shared = CDCoordinator()
    
    static var mainContext: NSManagedObjectContext {
        return shared.persistentContainer.viewContext
    }
    
    static func getChildContext() -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childMOC.parent = CDCoordinator.shared.persistentContainer.viewContext
        return childMOC
    }
    
    /**
     Saves a child MOC and merges changes into the shared parent singleton MOC.
     Because multiple threads calling save on the same parent MOC will crash, this block is scheduled to run on the main thread.
     Additionally, in order to catch errors and avoid multiple child MOC changes saving while another child MOC is being saved and merged, both the child and parent saves are executed synchronously.
     - parameter moc: The child MOC whose changes to save and merge.
     */
    static func saveAndMergeChanges(_ moc: NSManagedObjectContext) throws {
        do {
            try DispatchQueue.main.sync {
                try moc.save()
                try CDCoordinator.mainContext.save()
            }
        } catch {
            CDCoordinator.mainContext.rollback()
            throw ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                              ["error.localizedDescription": error.localizedDescription])
        }
    }
    
}
