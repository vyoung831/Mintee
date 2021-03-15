//
//  TestContainer.swift
//  MuTests
//
//  Created by Vincent Young on 6/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData
@testable import Mintee

class TestContainer {
    
    static var testShared = TestContainer()
    static var testMoc = testShared.persistentContainer.viewContext
    
    /*
     A test NSPersistentContainer that saves to an in-memory store and who's MOC is used for unit testing.
     To avoid having multiple NSEntityDescriptions of the same NSManagedObject, this var uses the NSManagedObjectModel that CDCoordinator's static shared container had already loaded and registered
     */
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let mom = CDCoordinator.shared.persistentContainer.managedObjectModel
        let container = NSPersistentCloudKitContainer(name: "Mu", managedObjectModel: mom)
        
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        container.loadPersistentStores(completionHandler: { description, error in
            if error != nil {
                print(error.debugDescription)
            }
        })
        
        return container
    }()
    
}
